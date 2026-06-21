use strict;
use warnings;

use Cwd qw( getcwd );
use File::Temp qw( tempdir );
use FindBin qw( $Bin );
use JSON::PP qw( decode_json );
use Path::Tiny qw( path );
use Test::More;

my $script = path( $Bin, '..', 'script', 'render-incoming.pl' )->realpath;
ok( -f $script, 'render-incoming script exists' );

my $tmp = tempdir( CLEANUP => 1 );
my $cwd = getcwd();
chdir $tmp or die "Could not chdir to temp dir: $!";

path( '2025', 'incoming' )->mkpath;
path( '2025', 'incoming', 'first-post.pod' )->spew_utf8("=head1 hello\n");
path( '2025', 'incoming', 'banner.png' )->spew_raw("image");

my $cmd = "PERL_ADVENT_RENDER_INCOMING_SKIP_BUILD=1 $^X $script --year 2025";
my $output = `$cmd 2>&1`;
is( $? >> 8, 0, 'render-incoming runs successfully with --year' )
    or diag $output;

my @rendered = path( '2025', 'articles' )->children(qr/\.pod$/);
is( scalar @rendered, 1, 'one incoming article was copied to articles/' );
like( $rendered[0]->basename, qr/^2025-12-\d{2}\.pod$/, 'rendered filename uses requested year' );

ok( path( '2025', 'share', 'static', 'banner.png' )->exists,
    'non-pod incoming asset copied to share/static' );

ok( path('incoming-mappings.json')->exists, 'mapping file was written' );
my $mapping_data = decode_json( path('incoming-mappings.json')->slurp_utf8 );
is( scalar @$mapping_data, 1, 'mapping contains one entry' );
is( $mapping_data->[0]{incoming}, '2025/incoming/first-post.pod',
    'mapping incoming path uses requested year' );
like( $mapping_data->[0]{html}, qr/^2025-12-\d{2}\.html$/, 'mapping html filename uses requested year' );

chdir $cwd or die "Could not chdir back to original directory: $!";

done_testing;
