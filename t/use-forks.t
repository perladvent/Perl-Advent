#!/usr/bin/env perl
use v5.26;
use warnings;

use Test::More;
use FindBin;
use File::Temp qw( tempdir );
use Path::Tiny qw( path );

my $root    = path( $FindBin::Bin, '..' )->realpath;
my $snippet = $root->child( 'script', 'use-forks.sh' );

# Runs $cmd in bash after sourcing $snippet; returns combined output, sets $?.
sub with_forks {
    my ( $snippet, $cmd ) = @_;
    open my $fh, '-|', 'bash', '-c', 'exec 2>&1; set -e; source "$1"; eval "$2"', '_', $snippet, $cmd
        or die "bash: $!";
    my $out = do { local $/; <$fh> };
    close $fh;
    return $out;
}

subtest 'unpopulated submodule fails noisily' => sub {
    my $fake = path( tempdir( CLEANUP => 1 ) );
    $fake->child('script')->mkpath;
    $snippet->copy( $fake->child( 'script', 'use-forks.sh' ) );
    $fake->child( 'inc', $_, 'lib' )->mkpath
        for qw( WWW-AdventCalendar Pod-Elemental-Transformer-SynHi );
    $fake->child( 'inc', 'PPI-HTML' )->mkpath;

    my $err = with_forks( $fake->child( 'script', 'use-forks.sh' ), 'echo survived' );
    isnt $?, 0, 'exits non-zero';
    like $err, qr{inc/PPI-HTML.*make init}, 'names the missing fork and the fix';
    unlike $err, qr{survived}, 'stops the sourcing script';
};

subtest 'real repo resolves advcal to the inc/ fork' => sub {
    chomp( my $advcal = with_forks( $snippet, 'command -v advcal' ) );
    is $advcal, $root->child( 'script', 'bin', 'advcal' )->stringify,
        'advcal on PATH is the wrapper';
    like with_forks( $snippet, 'advcal --help' ), qr{--https},
        'advcal is the fork (stock CPAN advcal has no --https)';
    for (
        [ 'WWW::AdventCalendar',               'WWW-AdventCalendar' ],
        [ 'Pod::Elemental::Transformer::SynHi', 'Pod-Elemental-Transformer-SynHi' ],
        [ 'PPI::HTML',                         'PPI-HTML' ],
    ) {
        my ( $module, $fork ) = @$_;
        ( my $file = "$module.pm" ) =~ s{::}{/}g;
        is with_forks( $snippet, qq{perl -M$module -e 'print \$INC{"$file"}'} ),
            $root->child( 'inc', $fork, 'lib', $file )->stringify,
            "$module loads from inc/";
    }
};

done_testing;
