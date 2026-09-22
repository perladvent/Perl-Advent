#!/usr/bin/env perl
use v5.26;
use warnings;
use open qw(:std :encoding(UTF-8));
use utf8;
use experimental qw(signatures);

use Test::More;
use File::Temp qw(tempfile);
use File::Spec;
use FindBin;
use YAML::XS ();

use PerlAdvent::Authors qw(
    canonical_author
    display_name
    load_aliases
    normalize_key
    parse_author_from_header
    yaml_escape_dq
);

# Run a repo script with the repo root as cwd (so FindBin/relative paths
# resolve), silence its stdout/stderr, and return the raw wait status ($?).
sub run_in_repo {
    my ( $repo, @cmd ) = @_;
    my $pid = fork // die "fork failed: $!";
    if ( $pid == 0 ) {
        chdir $repo or die "chdir: $!";
        open STDOUT, '>', File::Spec->devnull;
        open STDERR, '>', File::Spec->devnull;
        exec @cmd;
        exit 127;
    }
    waitpid $pid, 0;
    return $?;
}

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

    # A colon-less line in the (untrusted, free-form) header block must not
    # shift the key/value pairing and drop the author.
    is( parse_author_from_header("strayline\nAuthor: Jane Doe"), 'Jane Doe',
        'colon-less header line does not corrupt author extraction' );
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

subtest 'Ricker variants canonicalize via the shipped alias file' => sub {
    my $aliases = load_aliases("$FindBin::Bin/../authors-aliases.yaml");
    for my $variant (
        "Bill Ricker",
        "Bill 'N1VUX' Ricker",
        "William 'n1vux' Ricker",
    ) {
        is( canonical_author( $variant, $aliases ), 'William Ricker',
            "'$variant' -> William Ricker" );
    }
};

subtest 'yaml_escape_dq round-trips through a YAML double-quoted scalar' => sub {
    for my $orig (
        'Arthur Axel "fREW" Schmidt',
        'C:\Users\Name',
        'Ends with backslash\\',
        'both " and \\ together',
        'plain name',
    ) {
        my $escaped = yaml_escape_dq($orig);
        my ($round) = YAML::XS::Load(qq{"$escaped"});
        is( $round, $orig, "round-trips: $orig" );
    }

    is( yaml_escape_dq(undef), '', 'undef becomes empty string' );

    my $ctrl = "line1\nline2\ttab";
    my ($round) = YAML::XS::Load( q{"} . yaml_escape_dq($ctrl) . q{"} );
    unlike( $round, qr/[\x00-\x1f]/, 'control chars neutralized' );
};

subtest 'year2yaml writes a parseable block to an outfile' => sub {
    my $repo = "$FindBin::Bin/..";
    my ( $fh, $outfile ) =
        tempfile( 'year2yaml-XXXXXX', DIR => ($ENV{TMPDIR} // '/tmp'), UNLINK => 1 );
    close $fh;

    my $rc = run_in_repo( $repo, $^X, 'year2yaml', '2011', $outfile );

    is( $rc, 0, 'year2yaml exited cleanly' ) or diag "rc=$rc";

    my $data = eval { YAML::XS::LoadFile($outfile) };
    ok( !$@, 'outfile parses as YAML' ) or diag $@;
    ok( ref $data eq 'HASH' && $data->{2011}, 'has a 2011 block' );

    my $with_author = 0;
    for my $day ( values %{ $data->{2011} // {} } ) {
        for my $entry ( @{ $day // [] } ) {
            $with_author++ if defined $entry->{author} && length $entry->{author};
        }
    }
    ok( $with_author > 0, "entries carry author values ($with_author found)" );
};

subtest 'year2yaml handles a year with non-ASCII author names' => sub {
    # Regression: the pre-append YAML validation must encode to UTF-8 bytes,
    # or an accented author (2018 has several) trips "invalid trailing UTF-8
    # octet" and wrongly blocks the append.
    my $repo = "$FindBin::Bin/..";
    plan skip_all => 'no 2018/articles on disk'
        unless -d "$repo/2018/articles";

    my ( $fh, $outfile ) =
        tempfile( 'year2yaml-utf8-XXXXXX', DIR => ($ENV{TMPDIR} // '/tmp'), UNLINK => 1 );
    close $fh;

    my $rc = run_in_repo( $repo, $^X, 'year2yaml', '2018', $outfile );

    is( $rc, 0, 'year2yaml 2018 exited cleanly (did not die on the UTF-8 gate)' )
        or diag "rc=$rc";

    my $data = eval { YAML::XS::LoadFile($outfile) };
    ok( !$@ && ref $data eq 'HASH' && $data->{2018}, 'outfile parses with a 2018 block' )
        or diag $@;

    my $has_accented = 0;
    for my $day ( values %{ $data->{2018} // {} } ) {
        for my $entry ( @{ $day // [] } ) {
            $has_accented = 1
                if defined $entry->{author} && $entry->{author} =~ /[^\x00-\x7F]/;
        }
    }
    ok( $has_accented, 'an accented author round-trips into the output' );
};

done_testing();
