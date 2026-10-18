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

like $out, qr{PORT=9123 \./script/preview-article\.sh}, 'PORT reaches preview-article.sh';
my @ports = $out =~ /--port (\S+)/g;
ok @ports, 'recipes serve on a --port';
is_deeply [ grep { $_ ne '9123' } @ports ], [], 'every --port honours PORT=';

done_testing;
