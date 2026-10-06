#!/usr/bin/env perl
use v5.26;
use warnings;
use open qw(:std :encoding(UTF-8));

use Test::More;
use FindBin;
use Path::Tiny qw( path );

my $root = path( $FindBin::Bin, '..' );

sub slurp { $root->child(@_)->slurp_utf8 }

subtest 'CNAME' => sub {
    is slurp('CNAME'), "perladvent.org\n", 'CNAME names the custom domain';
};

subtest 'build-site.sh deploys root files' => sub {
    my $build = slurp( 'script', 'build-site.sh' );
    like $build, qr{^cp CNAME out/$}m,          'copies CNAME into out/';
    like $build, qr{^cp \./\*\.html out/$}m,    'copies root *.html (404.html) into out/';
};

subtest '404.html' => sub {
    my $html = slurp('404.html');

    like $html, qr{<html lang="en">},                      'has lang';
    like $html, qr{<meta charset="UTF-8">},                'has charset';
    like $html, qr{<meta name="viewport"},                 'has viewport';
    like $html, qr{<meta name="robots" content="noindex">}, 'is noindex';
    like $html, qr{<title>[^<]+</title>},                  'has title';

    my @urls = $html =~ m{(?:href|src)="([^"]+)"}g;
    push @urls, $html =~ m{url\(\s*["']?([^"')\s]+)}g;
    ok scalar @urls, 'found links and assets';

    my %url = map { $_ => 1 } @urls;
    ok $url{$_}, "links to $_" for qw( / /archives.html /archives-AZ.html );

    # GitHub Pages serves the 404 at the requested path, so a relative URL
    # would resolve against e.g. /2019/missing/ and break.
    for my $u ( sort keys %url ) {
        like $u, qr{^/}, "$u is root-absolute";
    }

    like $html, qr{<link rel="stylesheet" href="/2026/style\.css">},
        'uses the 2026 theme stylesheet';

    # Assets must exist in the build: /YEAR/style.css is rendered from
    # YEAR/share/templates/, other /YEAR/x comes from YEAR/share/static/x, and
    # root files are copied as-is.
    for my $u ( grep { m{\.(?:css|ico)$} } sort keys %url ) {
        my $src
            = $u =~ m{^/(\d{4})/(style\.css)$} ? $root->child( $1, 'share', 'templates', $2 )
            : $u =~ m{^/(\d{4})/([^/]+)$}      ? $root->child( $1, 'share', 'static',    $2 )
            :                                    $root->child( substr( $u, 1 ) );
        ok $src->exists, "$u exists in the repo";
    }
};

done_testing;
