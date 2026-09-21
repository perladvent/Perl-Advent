#!/usr/bin/env perl
use v5.26;
use warnings;
use open qw(:std :encoding(UTF-8));
use utf8;
use experimental qw(signatures);

use Test::More;
use File::Temp qw(tempfile);

use PerlAdvent::Authors qw(
    parse_author_from_header
    display_name
    normalize_key
    load_aliases
    canonical_author
    decode_legacy_entities
    parse_legacy_byline
    parse_advent_author_tag
    legacy_article_path
);

subtest 'parse_author_from_header' => sub {
    my $header = "Title: Something\nTopic: Foo::Bar\nAuthor: Jane Doe <jane\@example.com>";
    is( parse_author_from_header($header), 'Jane Doe <jane@example.com>',
        'extracts the Author value' );

    my $lc = "title: x\nauthor: lowercase person <lc\@example.com>";
    is( parse_author_from_header($lc), 'lowercase person <lc@example.com>',
        'case-insensitive author: key' );

    is( parse_author_from_header("Title: x\nTopic: Foo"), undef,
        'missing author header returns undef' );

    is( parse_author_from_header(undef), undef, 'undef input returns undef' );
};

subtest 'display_name variants' => sub {
    is( display_name('Jane Doe <jane@example.com>'), 'Jane Doe',
        'Name <email>' );
    is( display_name('Sawyer X (xsawyerx@cpan.org)'), 'Sawyer X',
        'Name (email)' );
    is( display_name('Randal Schwartz'), 'Randal Schwartz',
        'name-only' );

    is( display_name('olaf@wundersolutions.com'), 'olaf@wundersolutions.com',
        'email-only falls back to the email as the name' );

    is( display_name('Arthur Axel "fREW" Schmidt <frew@cpan.org>'),
        'Arthur Axel "fREW" Schmidt',
        'embedded quotes are preserved' );

    is( display_name('Csaba Simándi <x1m4nd1@gmail.com>'), 'Csaba Simándi',
        'UTF-8 name preserved' );
};

subtest 'double-space before email collapses to same display name' => sub {
    my $single = display_name('Mark Fowler <mark@twoshortplanks.com>');
    my $double = display_name('Mark Fowler  <mark@twoshortplanks.com>');
    is( $double, $single, 'double space yields identical display name' );
    is( normalize_key($double), normalize_key($single),
        'and identical grouping key' );
};

subtest 'normalize_key merges case and spacing' => sub {
    is( normalize_key('Ricardo Signes'), normalize_key('ricardo  signes'),
        'case and internal spacing folded together' );
};

subtest 'aliases map a variant to the canonical name' => sub {
    my ( $fh, $path ) = tempfile( UNLINK => 1 );
    binmode $fh, ':encoding(UTF-8)';
    print {$fh} <<'YAML';
"olaf@wundersolutions.com": "Olaf Alders"
"Ricardo SIGNES": "Ricardo Signes"
YAML
    close $fh;

    my $aliases = load_aliases($path);

    is( canonical_author( 'olaf@wundersolutions.com', $aliases ), 'Olaf Alders',
        'email-only raw value mapped to canonical name' );
    is( canonical_author( 'Ricardo SIGNES <rjbs@cpan.org>', $aliases ),
        'Ricardo Signes',
        'derived display name mapped via alias' );
    is( canonical_author( 'Jane Doe <jane@example.com>', $aliases ), 'Jane Doe',
        'non-aliased author passes through to display name' );
};

subtest 'load_aliases on a missing file returns empty hashref' => sub {
    my $aliases = load_aliases('/no/such/file/authors-aliases.yaml');
    is_deeply( $aliases, {}, 'absent file yields {}' );
    is( canonical_author( 'Jane Doe <jane@example.com>', $aliases ), 'Jane Doe',
        'canonical_author works with an empty alias map' );
};

subtest 'parse_legacy_byline extracts <h3>by NAME</h3>' => sub {
    is( parse_legacy_byline('<h3 align="center">by Jerrad Pierce</h3>'),
        'Jerrad Pierce', 'lower-case tag' );
    is( parse_legacy_byline('<H3 ALIGN="CENTER">by Bill Ricker</H3>'),
        'Bill Ricker', 'upper-case tag (case-insensitive)' );
    is( parse_legacy_byline('<H3 align=center>by Jerrad Pierce</H3>'),
        'Jerrad Pierce', 'unquoted attribute value' );

    is( parse_legacy_byline('<h3 align="center">by David Westbrook &amp; Jerrad Pierce</h3>'),
        'David Westbrook & Jerrad Pierce',
        'co-authors decoded and kept as a single string' );

    is( parse_legacy_byline('<p>no byline here</p>'), undef,
        'no <h3>by ...</h3> returns undef' );
    is( parse_legacy_byline(undef), undef, 'undef input returns undef' );
};

subtest 'decode_legacy_entities' => sub {
    is( decode_legacy_entities('A &amp; B'), 'A & B', 'single &amp;' );
    is( decode_legacy_entities('A &amp;amp; B'), 'A & B',
        'double-encoded &amp;amp;' );
    is( decode_legacy_entities("O&#39;Brien"), "O'Brien", 'numeric apostrophe' );
    is( decode_legacy_entities(undef), undef, 'undef passes through' );
};

subtest 'parse_advent_author_tag' => sub {
    my $pod = "=head1 NAME\n\n=for advent_author Yanick Champoux\n\n=cut\n";
    is( parse_advent_author_tag($pod), 'Yanick Champoux',
        'extracts =for advent_author' );
    is( parse_advent_author_tag("=for advent_author Bill Ricker   \n"),
        'Bill Ricker', 'trailing whitespace trimmed' );
    is( parse_advent_author_tag("no author tag here\n"), undef,
        'absent tag returns undef' );
};

subtest 'legacy_article_path routing' => sub {
    is( legacy_article_path( 2003, '10' ), '2003/10th/index.html',
        '2001-2004 use ordinal directory (10th)' );
    is( legacy_article_path( 2002, '01' ), '2002/1st/index.html',
        'ordinal 1st' );
    is( legacy_article_path( 2001, '02' ), '2001/2nd/index.html',
        'ordinal 2nd' );
    is( legacy_article_path( 2004, '23' ), '2004/23rd/index.html',
        'ordinal 23rd' );
    is( legacy_article_path( 2004, '21' ), '2004/21st/index.html',
        'ordinal 21st' );
    is( legacy_article_path( 2004, '11' ), '2004/11th/index.html',
        'ordinal 11th (teens are th)' );

    is( legacy_article_path( 2008, '07' ), '2008/7/index.html',
        'other legacy years use the integer directory' );
    is( legacy_article_path( 2000, '25' ), '2000/25/index.html',
        '2000 uses the integer directory' );
    is( legacy_article_path( 2010, '5' ), '2010/5/index.html',
        'integer day input works too' );
};

done_testing();
