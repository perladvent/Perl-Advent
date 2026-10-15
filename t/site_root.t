#!/usr/bin/env perl
use v5.26;
use warnings;
use open qw(:std :encoding(UTF-8));

use Test::More;
use FindBin;
use Mojo::DOM;
use Path::Tiny qw( path );

my $root = path( $FindBin::Bin, '..' );

sub slurp { $root->child(@_)->slurp_utf8 }

subtest 'CNAME' => sub {
    is slurp('CNAME'), "perladvent.org\n", 'CNAME names the custom domain';
};

subtest 'build-site.sh deploys root files' => sub {
    my $build = slurp( 'script', 'build-site.sh' );
    like $build, qr{^cp CNAME out/$}m,          'copies CNAME into out/';
    like $build, qr{^cp \./\*\.html out/$}m,    'copies root *.html (404.html) into out/';
};

# Every root-absolute URL a page loads or links to, from attributes and CSS.
sub urls {
    my ($dom) = @_;
    my @urls = ( $dom->find('[href]')->map( attr => 'href' )->each,
                 $dom->find('[src]')->map( attr => 'src' )->each );
    push @urls, $_->text =~ m{url\(\s*["']?([^"')\s]+)}g for $dom->find('style')->each;
    return { map { $_ => 1 } @urls };
}

# What every root page needs in its <head>.
sub head_ok {
    my ($dom) = @_;
    is $dom->at('html')->attr('lang'), 'en', 'has lang';
    is $dom->at('meta[charset]')->attr('charset'), 'UTF-8', 'has charset';
    ok $dom->at('meta[name=viewport]'), 'has viewport';
    like $dom->at('title')->text, qr/\S/, 'has title';
    is $dom->at('link[rel=stylesheet]')->attr('href'), '/2026/style.css',
        'uses the 2026 theme stylesheet';
}

subtest '404.html' => sub {
    my $dom = Mojo::DOM->new( slurp('404.html') );
    head_ok($dom);
    is $dom->at('meta[name=robots]')->attr('content'), 'noindex', 'is noindex';

    my $url = urls($dom);
    ok $url->{$_}, "links to $_" for qw( / /archives.html /archives-AZ.html );

    # GitHub Pages serves the 404 at the requested path, so a relative URL
    # would resolve against e.g. /2019/missing/ and break.
    like $_, qr{^/}, "$_ is root-absolute" for sort keys %$url;

    # Assets must exist in the build: /YEAR/style.css is rendered from
    # YEAR/share/templates/, other /YEAR/x comes from YEAR/share/static/x, and
    # root files are copied as-is.
    for my $u ( grep { m{\.(?:css|ico)$} } sort keys %$url ) {
        my $src
            = $u =~ m{^/(\d{4})/(style\.css)$} ? $root->child( $1, 'share', 'templates', $2 )
            : $u =~ m{^/(\d{4})/([^/]+)$}      ? $root->child( $1, 'share', 'static',    $2 )
            :                                    $root->child( substr( $u, 1 ) );
        ok $src->exists, "$u exists in the repo";
    }
};

subtest 'index.html' => sub {
    my $dom = Mojo::DOM->new( slurp('index.html') );
    head_ok($dom);
    ok !$dom->at('meta[name=robots]'), 'is indexable';

    my $url = urls($dom);
    ok $url->{$_}, "links to $_"
        for qw( /archives.html /archives-AZ.html /FAQ-submit.html /FAQ.html /contact.html );

    like $dom->at('link[rel=alternate][type="application/atom+xml"]')->attr('href'),
        qr{^/\d{4}/atom\.xml$}, 'advertises the upcoming calendar feed';
    is $dom->at('link[rel=canonical]')->attr('href'), 'https://perladvent.org/',
        'declares the bare root as canonical';
    like $dom->at('meta[name=description]')->attr('content'), qr/\S/, 'has a description';
    is $dom->at('meta[property="og:image"]')->attr('content'),
        'https://perladvent.org/2026/og-default.png', 'shares with the 2026 card image';
    ok -e $root->child(qw( 2026 share static og-default.png )), 'that image is in the build';
    like slurp( 'script', 'prepare-new-year.sh' ), qr{atom\\\.xml.*index\.html}m,
        'prepare-new-year.sh moves the feed link';
};

subtest 'coming-soon feed' => sub {
    like slurp( 'script', 'build-site.sh' ),
        qr{^\s*\.\./script/coming-soon-feed\.sh "\$year" "\$target"$}m,
        'build-site.sh swaps in the static feed';
    like slurp( 'script', 'uat-preview.sh' ),
        qr{^script/coming-soon-feed\.sh "\$YEAR" "\$OUT"$}m,
        'uat-preview.sh swaps in the static feed';

    my %ini = slurp( '2026', 'advent.ini' ) =~ /^(\w+)\s*=\s*(.*?)\s*$/mg;
    my $script = $root->child( 'script', 'coming-soon-feed.sh' );
    my $out    = Path::Tiny->tempdir;
    my $feed   = $out->child('atom.xml');

    # What advcal writes before its start_date, trimmed to the parts that matter.
    my $patience = <<"XML";
<feed xmlns="http://www.w3.org/2005/Atom"><id>$ini{uri}</id>
<entry><title>$ini{title} is Coming</title>
<summary>The first door opens in 47 days...</summary></entry></feed>
XML
    $feed->spew_utf8($patience);
    is system( $script, 2026, "$out" ), 0, 'runs on a pre-season build';
    my $xml = $feed->slurp_utf8;
    unlike $xml, qr{@}, 'fills every placeholder';

    my $atom = Mojo::DOM->new->xml(1)->parse($xml);
    is $atom->at('feed > id')->text, $ini{uri}, 'keeps advcal\'s feed id';
    is $atom->at('feed > link[rel=self]')->attr('href'), "$ini{uri}atom.xml",
        'keeps advcal\'s self link';
    is $atom->at('feed > title')->text, $ini{title}, 'keeps advcal\'s feed title';
    is $atom->at('feed > author > name')->text, $ini{editor}, 'keeps advcal\'s feed author';
    is $atom->find('entry')->size, 1, 'has a single entry';
    is $atom->at('entry > title')->text,
        'Year 27 of The Perl Advent Calendar opens on December 1st', 'counts the year from 2000';
    unlike $atom->all_text, qr{\b\d+ days?\b}, 'has no countdown that would change between builds';
    ok !$out->child('atom.xml.tmp')->exists, 'leaves no temp file behind';

    my $open = <<"XML";
<feed xmlns="http://www.w3.org/2005/Atom"><id>$ini{uri}</id>
<entry><title>Day one</title><summary>An article</summary></entry></feed>
XML
    $feed->spew_utf8($open);
    is system( $script, 2026, "$out" ), 0, 'runs on an open calendar';
    is $feed->slurp_utf8, $open, 'leaves advcal\'s feed alone once the calendar opens';

    isnt system( "$script 2026 >/dev/null 2>&1" ), 0, 'refuses a missing output dir';
    isnt system( "$script 26 $out >/dev/null 2>&1" ), 0, 'refuses a malformed year';
};

# advcal parses every file in a calendar's article_dir as an article, so
# anything else there (a .gitkeep, an editor swap file) breaks the build from
# December 1.
subtest 'article dirs hold only articles' => sub {
    for my $dir ( grep { $_->basename =~ /\A\d{4}\z/ } $root->children ) {
        my $articles = $dir->child('articles');
        next unless $articles->is_dir;
        my @stray = grep { $_->basename !~ /\A\d{4}-\d\d-\d\d\.pod\z/ } $articles->children;
        is_deeply [ map { $_->relative($root)->stringify } @stray ], [],
            "$articles holds only YYYY-MM-DD.pod files";
    }
};

done_testing;
