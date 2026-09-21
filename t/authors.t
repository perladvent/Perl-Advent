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

done_testing();
