#!/usr/bin/env perl
use v5.26;
use warnings;

use lib 'lib';
use lib 'inc/WWW-AdventCalendar/lib';
use lib 'inc/Pod-Elemental-Transformer-SynHi/lib';

use Perl::Advent::RSSModePatch;
use Test::More;
use WWW::AdventCalendar::Article;

my $calendar_stub = bless { uri => 'https://example.test/' }, 'WWW::AdventCalendar';

my $article = WWW::AdventCalendar::Article->new(
    calendar => $calendar_stub,
    date     => bless({}, 'DateTime'),
    title    => 'RSS Mode test',
    topic    => 'Testing',
    author   => 'Tester <tester@example.test>',
    body     => <<'POD',
=for web_only <p>Visible only on web pages.</p>

=for rss_only <p>Visible only in feed summaries.</p>

=for html <p>Visible in both web and feed output.</p>

Shared paragraph.
POD
);

my $web_html = $article->body_html;
my $rss_html = $article->body_html_for_rss;

like $web_html, qr/Visible only on web pages\./, 'web_html keeps web_only content';
unlike $web_html, qr/Visible only in feed summaries\./, 'web_html strips rss_only content';

like $rss_html, qr/Visible only in feed summaries\./, 'body_html_for_rss keeps rss_only content';
unlike $rss_html, qr/Visible only on web pages\./, 'body_html_for_rss strips web_only content';

like $web_html, qr/Shared paragraph\./, 'web_html keeps shared content';
like $rss_html, qr/Shared paragraph\./, 'body_html_for_rss keeps shared content';
like $web_html, qr/Visible in both web and feed output\./, 'web_html keeps normal html blocks';
like $rss_html, qr/Visible in both web and feed output\./, 'body_html_for_rss keeps normal html blocks';

done_testing;
