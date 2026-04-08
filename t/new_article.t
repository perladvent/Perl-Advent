use v5.10;
use strict;
use warnings;

use Cwd qw(getcwd);
use File::Spec::Functions qw(catfile catdir);
use File::Temp qw(tempdir);
use Test::More;

use lib 'lib';
use Perl::Advent::NewArticle qw(default_year slugify_title);

sub write_advent_ini {
    my ( $root, $year ) = @_;
    my $year_dir = catdir( $root, $year );
    mkdir $year_dir or die "Could not create <$year_dir>: $!" unless -d $year_dir;
    my $advent_ini = catfile( $year_dir, 'advent.ini' );
    open my $fh, '>:encoding(UTF-8)', $advent_ini or die "Could not open <$advent_ini>: $!";
    print {$fh} "year = $year\n";
    close $fh;
}

sub slurp_file {
    my ($path) = @_;
    open my $fh, '<:encoding(UTF-8)', $path or die "Could not open <$path>: $!";
    local $/;
    my $content = <$fh>;
    close $fh;
    return $content;
}

my $tmp = tempdir( CLEANUP => 1 );
write_advent_ini( $tmp, 2024 );
write_advent_ini( $tmp, 2025 );

is( default_year( $tmp, 2025 ), 2025, 'default year prefers current calendar year when available' );
is( default_year( $tmp, 2026 ), 2025, 'default year falls back to latest configured year' );

my $empty_tmp = tempdir( CLEANUP => 1 );
is( default_year( $empty_tmp, 2026 ), 2026, 'default year falls back to current year when no calendars exist' );

is( slugify_title('OpenAPI::Linter'), 'openapi-linter', 'slugify handles module names' );
is( slugify_title('  Hello, Perl Advent!  '), 'hello-perl-advent', 'slugify trims punctuation and edges' );

my $repo_root = getcwd();
my $script    = catfile( $repo_root, 'script', 'new_article' );
my $orig_cwd  = getcwd();

{
    chdir $tmp or die "Could not chdir to <$tmp>: $!";
    my @cmd = (
        $^X, $script,
        '--title',  'OpenAPI::Linter',
        '--topic',  'OpenAPI::Linter',
        '--author', 'Test Author <test@example.com>',
    );
    is( system(@cmd), 0, 'new_article creates file in default detected year' );

    my $path = catfile( $tmp, '2025', 'incoming', 'openapi-linter.pod' );
    ok( -f $path, 'article created in 2025/incoming using detected default year' );

    my $content = slurp_file($path);
    like( $content, qr/^Author: Test Author <test\@example\.com>$/m, 'author header written' );
    like( $content, qr/^Title: OpenAPI::Linter$/m, 'title header written' );
    like( $content, qr/^Topic: OpenAPI::Linter$/m, 'topic header written' );
}

{
    chdir $tmp or die "Could not chdir to <$tmp>: $!";
    my @cmd = (
        $^X, $script,
        '--year',   '2024',
        '--title',  'Year Override',
        '--topic',  'Some::Topic',
        '--author', 'Test Author <test@example.com>',
    );
    is( system(@cmd), 0, 'new_article supports explicit year override' );
    ok( -f catfile( $tmp, '2024', 'incoming', 'year-override.pod' ), 'article created in override year' );
}

chdir $orig_cwd or die "Could not restore cwd <$orig_cwd>: $!";

done_testing();
