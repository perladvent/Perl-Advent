#!/usr/bin/env perl
use v5.26;
use warnings;

use Test::More;
use FindBin;
use File::Temp qw( tempdir );
use Path::Tiny qw( path );

my $root    = path( $FindBin::Bin, '..' )->realpath;
my $snippet = $root->child( 'script', 'use-forks.sh' );

subtest 'unpopulated submodule fails noisily' => sub {
    my $fake = path( tempdir( CLEANUP => 1 ) );
    $fake->child('script')->mkpath;
    $snippet->copy( $fake->child( 'script', 'use-forks.sh' ) );
    $fake->child( 'inc', $_, 'lib' )->mkpath
        for qw( WWW-AdventCalendar Pod-Elemental-Transformer-SynHi );
    $fake->child( 'inc', 'PPI-HTML' )->mkpath;

    my $err = `bash -c 'source "\$1"; echo survived' _ $fake/script/use-forks.sh 2>&1`;
    isnt $?, 0, 'exits non-zero';
    like $err, qr{inc/PPI-HTML.*make init}, 'names the missing fork and the fix';
    unlike $err, qr{survived}, 'stops the sourcing script';
};

subtest 'real repo resolves advcal to the inc/ fork' => sub {
    my $with_forks = sub {
        open my $fh, '-|', 'bash', '-c', 'source "$1"; eval "$2" 2>&1', '_', $snippet, $_[0]
            or die "bash: $!";
        local $/;
        return scalar <$fh>;
    };

    chomp( my $advcal = $with_forks->('command -v advcal') );
    is $advcal, $root->child( 'script', 'bin', 'advcal' )->stringify,
        'advcal on PATH is the wrapper';
    like $with_forks->('advcal --help'), qr{--https},
        'advcal is the fork (stock CPAN advcal has no --https)';
    is $with_forks->(q{perl -MWWW::AdventCalendar -e 'print $INC{"WWW/AdventCalendar.pm"}'}),
        $root->child(qw( inc WWW-AdventCalendar lib WWW AdventCalendar.pm ))->stringify,
        'WWW::AdventCalendar loads from inc/';
};

done_testing;
