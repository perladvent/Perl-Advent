#!/usr/bin/env perl
use v5.26;
use warnings;

use Test::More;
use FindBin;
use File::Temp qw( tempdir );
use Path::Tiny qw( path );

my $root = path( $FindBin::Bin, '..' )->realpath;

# A fake repo whose build/render steps and chown/http_this just log their args.
my $fake = path( tempdir( CLEANUP => 1 ) );
my $log  = $fake->child('log');
$fake->child('a.pod')->touch;
$fake->child('script')->mkpath;
$root->child( 'script', 'docker-preview.sh' )->copy( $fake->child('script') );
my %stub = (
    'script/build-site.sh'      => 'exit "${BUILD_RC:-0}"',
    'script/preview-article.sh' => 'exit "${RENDER_RC:-0}"',
    'bin/chown'                 => '',
    'bin/http_this'             => '',
);
for my $file ( keys %stub ) {
    my $name = path($file)->basename;
    $fake->child($file)->touchpath->spew(
        qq{#!/bin/sh\necho "$name \$*" >> "$log"\n$stub{$file}\n} );
    $fake->child($file)->chmod(0755);
}

sub preview {
    my ( $env, @args ) = @_;
    $log->spew('');
    local $ENV{PATH} = "$fake/bin:$ENV{PATH}";
    local @ENV{ keys %$env } = values %$env;
    system 'bash', $fake->child( 'script', 'docker-preview.sh' ), @args;
    return ( $? >> 8, $log->slurp );
}

my %base = ( ARTICLE => 'a.pod', HOST_UID_GID => '1:2', PREVIEW_PORT => 9999 );

subtest 'render ok' => sub {
    my ( $rc, $log ) = preview( {%base} );
    is $rc, 0, 'exits 0';
    like $log, qr{^preview-article\.sh a\.pod$}m, 'renders ARTICLE';
    like $log, qr{^chown -R -- 1:2 out$}m, 'hands out/ back';
    unlike $log, qr{build-site}, 'does not rebuild the site';
    unlike $log, qr{http_this}, 'does not serve';
};

subtest 'render fails' => sub {
    my ( $rc, $log ) = preview( { %base, RENDER_RC => 3 }, '--serve' );
    is $rc, 3, 'propagates the render status';
    like $log, qr{^chown -R -- 1:2 out$}m, 'still hands out/ back';
    unlike $log, qr{http_this}, 'does not serve';
};

subtest 'build fails' => sub {
    my ( $rc, $log ) = preview( { %base, BUILD_RC => 4 }, '--serve' );
    is $rc, 4, 'propagates the build status';
    like $log, qr{^chown -R -- 1:2 out$}m, 'still hands out/ back';
    unlike $log, qr{preview-article|http_this}, 'neither renders nor serves';
};

subtest 'missing ARTICLE' => sub {
    my ( $rc, $log ) = preview( { %base, ARTICLE => 'nope.pod' }, '--serve' );
    isnt $rc, 0, 'exits non-zero';
    unlike $log, qr{build-site|http_this}, 'neither builds nor serves';
};

subtest 'no HOST_UID_GID' => sub {
    my ( $rc, $log ) = preview( { %base, HOST_UID_GID => '' } );
    is $rc, 0, 'exits 0';
    unlike $log, qr{chown}, 'skips chown';
};

subtest 'serve' => sub {
    my ( $rc, $log ) = preview( {%base}, '--serve' );
    is $rc, 0, 'exits 0';
    like $log, qr{
        ^build-site\.sh\s*\n
        preview-article\.sh\ a\.pod\n
        chown\ -R\ --\ 1:2\ out\n
        http_this\ out\ --host\ 0\.0\.0\.0\ --port\ 9999\ --autoindex$
    }mx, 'builds, renders, hands out/ back, then serves on PREVIEW_PORT';
};

done_testing;
