use v5.10;
use strict;
use warnings;

use Cwd qw(getcwd);
use File::Spec::Functions qw(catfile);
use File::Temp qw(tempdir);
use Test::More;

my $repo_root = getcwd();
my $script    = catfile( $repo_root, 'script', 'new_article' );

subtest 'sanity' => sub {
    ok( -e $script, "<$script> exists" );
    require_ok $script or BAIL_OUT("Could not load <$script>");
};

sub slurp_file {
    my ($path) = @_;
    open my $fh, '<:encoding(UTF-8)', $path or return;
    local $/;
    my $content = <$fh>;
    close $fh;
    return $content;
}

subtest 'slugify_title' => sub {
    my @cases = (
        [ 'OpenAPI::Linter',       'openapi-linter',   'handles module names' ],
        [ '  Hello, Perl Advent!  ', 'hello-perl-advent', 'trims punctuation and edges' ],
    );

    foreach my $case (@cases) {
        my ( $input, $expected, $label ) = @{$case};
        is(
            Perl::Advent::new_article::slugify_title($input),
            $expected,
            $label,
        );
    }
};

my $tmp          = tempdir( CLEANUP => 1 );
my $current_year = (localtime)[5] + 1900;

subtest 'script execution' => sub {
    my $title  = 'OpenAPI::Linter';
    my $topic  = 'OpenAPI::Linter';
    my $author = 'Test Author <test@example.com>';
    my $orig_cwd = getcwd();

    chdir $tmp or BAIL_OUT("Could not chdir to <$tmp>: $!");

    my @cmd = (
        $^X, $script,
        '--title',  $title,
        '--topic',  $topic,
        '--author', $author,
    );
    is( system(@cmd), 0, 'new_article creates file in current year by default' );

    my $path = catfile( $tmp, $current_year, 'incoming', 'openapi-linter.pod' );
    ok( -f $path, 'article created in current year incoming directory' );

    my $content = slurp_file($path);
    ok( defined $content, "slurped <$path>" ) or return;
    like( $content, qr/^Author: \Q$author\E$/m, 'author header written' );
    like( $content, qr/^Title: \Q$title\E$/m, 'title header written' );
    like( $content, qr/^Topic: \Q$topic\E$/m, 'topic header written' );

    my $override_year  = 2024;
    my $override_title = 'Year Override';
    @cmd = (
        $^X, $script,
        '--year',   $override_year,
        '--title',  $override_title,
        '--topic',  'Some::Topic',
        '--author', $author,
    );
    is( system(@cmd), 0, 'new_article supports explicit year override' );
    ok( -f catfile( $tmp, $override_year, 'incoming', 'year-override.pod' ), 'article created in override year' );

    chdir $orig_cwd or BAIL_OUT("Could not restore cwd <$orig_cwd>: $!");
};

done_testing();
