#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use charnames qw(:full);

use lib 'lib';
use lib 'inc/WWW-AdventCalendar/lib';

use DateTime;
use Test::More;
use WWW::AdventCalendar::Article;

{
    no warnings qw(redefine once);
    *WWW::AdventCalendar::uri = sub { shift->{uri} };
}

my $calendar = bless { uri => 'https://example.test/' }, 'WWW::AdventCalendar';

my $open_q  = "\N{LEFT-POINTING DOUBLE ANGLE QUOTATION MARK}";
my $close_q = "\N{RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK}";

my $body = <<"POD";
=encoding utf8

=begin perl

    ok( headerOK( \$str ), "${open_q}\$str${close_q} is OK" );

=end perl

    #!vim perl

          debug "${open_q}\$firstLine${close_q} is proper markdown ho, ho, ho";
POD

my $article = WWW::AdventCalendar::Article->new(
    date     => DateTime->new( year => 2024, month => 12, day => 15 ),
    author   => 'Test Author <test@example.com>',
    title    => 'UTF-8 render check',
    topic    => 'Encoding',
    body     => $body,
    calendar => $calendar,
);

my $html = $article->body_html;

like(
    $html,
    qr/\Q$open_q\E\$str\Q$close_q\E is OK/,
    'begin perl block keeps UTF-8 guillemets',
);

like(
    $html,
    qr/\Q$open_q\E<\/span><span class="synIdentifier">\$firstLine<\/span><span class="synConstant">\Q$close_q\E is proper markdown ho, ho, ho/s,
    '#!vim perl block keeps UTF-8 guillemets',
);

unlike(
    $html,
    qr/Â«/,
    'no double-encoded UTF-8 marker remains',
);

done_testing;
