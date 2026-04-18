use v5.10;
use strict;
use warnings;

use Cwd qw(getcwd);
use File::Spec::Functions qw(catfile);
use File::Temp qw(tempdir);
use Test::More;

require './script/new_article';

sub slurp_file {
    my ($path) = @_;
    open my $fh, '<:encoding(UTF-8)', $path or die "Could not open <$path>: $!";
    local $/;
    my $content = <$fh>;
    close $fh;
    return $content;
}

is(
    Perl::Advent::new_article::slugify_title('OpenAPI::Linter'),
    'openapi-linter',
    'slugify handles module names',
);

is(
    Perl::Advent::new_article::slugify_title('  Hello, Perl Advent!  '),
    'hello-perl-advent',
    'slugify trims punctuation and edges',
);

my $tmp = tempdir( CLEANUP => 1 );
my $repo_root = getcwd();
my $script    = catfile( $repo_root, 'script', 'new_article' );
my $orig_cwd  = getcwd();
my $current_year = (localtime)[5] + 1900;

{
    chdir $tmp or die "Could not chdir to <$tmp>: $!";
    my @cmd = (
        $^X, $script,
        '--title',  'OpenAPI::Linter',
        '--topic',  'OpenAPI::Linter',
        '--author', 'Test Author <test@example.com>',
    );
    is( system(@cmd), 0, 'new_article creates file in current year by default' );

    my $path = catfile( $tmp, $current_year, 'incoming', 'openapi-linter.pod' );
    ok( -f $path, 'article created in current year incoming directory' );

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
