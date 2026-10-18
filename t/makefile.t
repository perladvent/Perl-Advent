#!/usr/bin/env perl
use v5.26;
use warnings;

use Test::More;
use FindBin;
use File::Spec;
use Path::Tiny qw( path );

my $root = path( $FindBin::Bin, '..' );

plan skip_all => 'make not on PATH'
    unless grep { -x File::Spec->catfile( $_, 'make' ) } File::Spec->path;

# Dry run (-n): prints the recipes with variables expanded, runs nothing.
open my $make, '-|', 'make', '-n', '-C', "$root", 'preview', 'preview-tailnet',
    'ARTICLE=x.pod', 'PORT=9123'
    or die "Cannot run make: $!";
my $out = do { local $/; <$make> };
close $make;

# preview-build (via preview) and preview-tailnet each build, then serve, once.
is_deeply [ $out =~ m{\bPORT=(\S+) \./script/preview-article\.sh}g ], [ 9123, 9123 ],
    'PORT reaches preview-article.sh from both targets';
is_deeply [ $out =~ /--port (\S+)/g ], [ 9123, 9123 ], 'both servers honour PORT=';

done_testing;
