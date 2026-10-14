#!/usr/bin/env perl
use v5.26;
use warnings;
use open qw(:std :encoding(UTF-8));

use Test::More;
use FindBin;
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

subtest '404.html' => sub {
    my $html = slurp('404.html');

    like $html, qr{<html lang="en">},                      'has lang';
    like $html, qr{<meta charset="UTF-8">},                'has charset';
    like $html, qr{<meta name="viewport"},                 'has viewport';
    like $html, qr{<meta name="robots" content="noindex">}, 'is noindex';
    like $html, qr{<title>[^<]+</title>},                  'has title';

    my @urls = $html =~ m{(?:href|src)="([^"]+)"}g;
    push @urls, $html =~ m{url\(\s*["']?([^"')\s]+)}g;
    ok scalar @urls, 'found links and assets';

    my %url = map { $_ => 1 } @urls;
    ok $url{$_}, "links to $_" for qw( / /archives.html /archives-AZ.html );

    # GitHub Pages serves the 404 at the requested path, so a relative URL
    # would resolve against e.g. /2019/missing/ and break.
    for my $u ( sort keys %url ) {
        like $u, qr{^/}, "$u is root-absolute";
    }

    like $html, qr{<link rel="stylesheet" href="/2026/style\.css">},
        'uses the 2026 theme stylesheet';

    # Assets must exist in the build: /YEAR/style.css is rendered from
    # YEAR/share/templates/, other /YEAR/x comes from YEAR/share/static/x, and
    # root files are copied as-is.
    for my $u ( grep { m{\.(?:css|ico)$} } sort keys %url ) {
        my $src
            = $u =~ m{^/(\d{4})/(style\.css)$} ? $root->child( $1, 'share', 'templates', $2 )
            : $u =~ m{^/(\d{4})/([^/]+)$}      ? $root->child( $1, 'share', 'static',    $2 )
            :                                    $root->child( substr( $u, 1 ) );
        ok $src->exists, "$u exists in the repo";
    }
};

subtest 'index.html' => sub {
    my $html = slurp('index.html');

    like $html, qr{<html lang="en">},      'has lang';
    like $html, qr{<meta charset="UTF-8">}, 'has charset';
    like $html, qr{<meta name="viewport"}, 'has viewport';
    like $html, qr{<title>[^<]+</title>},  'has title';
    unlike $html, qr{name="robots"},       'is indexable';

    my %url = map { $_ => 1 } $html =~ m{(?:href|src)="([^"]+)"}g;
    ok $url{$_}, "links to $_"
        for qw( /archives.html /archives-AZ.html /FAQ-submit.html /FAQ.html /contact.html );

    like $html, qr{<link rel="stylesheet" href="/2026/style\.css">},
        'uses the 2026 theme stylesheet';

    like $html, qr{<link rel="alternate" type="application/atom\+xml"[^>]* href="/\d{4}/atom\.xml"},
        'advertises the upcoming calendar feed';
    like $html, qr{<link rel="canonical" href="https://perladvent\.org/">},
        'declares the bare root as canonical';
    like $html, qr{<meta name="description" content="[^"]+">}, 'has a description';
    like $html, qr{<meta property="og:image" content="https://perladvent\.org/2026/og-default\.png">},
        'shares with the 2026 card image';
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
    like $xml, qr{<id>\Q$ini{uri}\E</id>}, 'keeps advcal\'s feed id';
    like $xml, qr{<link href="\Q$ini{uri}\Eatom\.xml" rel="self"/>},
        'keeps advcal\'s self link';
    like $xml, qr{<title>\Q$ini{title}\E</title>}, 'keeps advcal\'s feed title';
    like $xml, qr{<author><name>\Q$ini{editor}\E</name></author>},
        'keeps advcal\'s feed author';
    like $xml, qr{<title>Year 27 of The Perl Advent Calendar opens on December 1st</title>},
        'counts the year from 2000';
    unlike $xml, qr{\b\d+ days?\b}, 'has no countdown that would change between builds';
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

done_testing;
