#!/usr/bin/env perl

=head1 SYNOPSIS

    perl script/check-site.pl https://perladvent.org --limit 10000 > bad-links.csv

=head1 DESCRIPTION

This simple script shows you a dump of the default report.  You're encouraged
to provide your own reporting callback in order to customize your report.

=cut

use strict;
use warnings;
use feature qw( say state );

use CHI ();
use Data::Printer filters => ['URI'];
use File::XDG              ();
use Getopt::Kingpin        ();
use HTTP::Status           qw( is_success );
use WWW::RoboCop           ();
use WWW::Mechanize::Cached ();

use LWP::Protocol::https;    ## no perlimports
my $ua
    = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36';

my $cache_dir = File::XDG->new( name => 'WWW-Robocop' )->cache_home;
$cache_dir->mkpath;

my $cache = CHI->new(
    driver   => 'File',
    root_dir => $cache_dir->stringify,
);

my $kingpin = Getopt::Kingpin->new;
$kingpin->flags->get('help')->short('h');

#<<<
my $start_url =
    $kingpin->arg( 'start_url', 'Start URL' )
            ->required
            ->string;

my $upper_limit =
    $kingpin->flag( 'limit', 'Max URLs to visit' )
            ->default(100)
            ->int;

my $verbose =
    $kingpin->flag( 'verbose', 'Verbose mode.' )
            ->short('v')
            ->bool;

my $outbound =
    $kingpin->flag( 'check-outbound-links', 'Check outbound links (default false)' )
            ->default(0)
            ->bool;
my $dump =
    $kingpin->flag( 'full-report', 'Dump full report (default false)' )
            ->default(0)
            ->bool;

my $verify =
    $kingpin->flag( 'verify-hostname', 'Verify hostname (default true)' )
            ->default(1)
            ->bool;
#>>>

$kingpin->parse;

if ($verbose) {
    require LWP::ConsoleLogger::Everywhere;
}

$start_url = URI->new($start_url);

unless ( $start_url->scheme ) {
    say "\n", '💩 URL must include a scheme 💩', "\n";
    $kingpin->help;
    exit(1);
}

my $robocop = WWW::RoboCop->new(
    is_url_allowed => sub {
        my $link          = shift;
        my $referring_url = shift;

        state $limit = 1;

        return 0 if $limit > $upper_limit;
        my $uri = URI->new( $link->url_abs );

        # If the link URI does not match the host but the referring_url matches
        # the host, then this is a 1st degree outbound link.  If outbound link
        # checking is enabled, we'll fetch the page in order to log the status
        # code etc, but we won't index any of the links on it.

        if (   ( $outbound && $referring_url->host eq $start_url->host )
            || ( $uri->host eq $start_url->host ) ) {
            ++$limit;
            return 1;
        }
        return 0;
    },
    ua => WWW::Mechanize::Cached->new(
        agent    => $ua,
        cache    => $cache,
        ssl_opts => { verify_hostname => $verify },
        timeout  => 5,
    ),
);

$robocop->crawl($start_url);

my %report = $robocop->get_report;
if ($dump) {
    p %report;
}

my @failures = sort { $a->{report}{referrer} cmp $b->{report}{referrer} }
    map { +{ url => $_, report => $report{$_} } }
    grep { !is_success( $report{$_}->{status} ) } keys %report;

for my $f (@failures) {
    printf(
        "%s,%s,%s\n", $f->{report}{referrer}, $f->{url},
        $f->{report}{status}
    );
}
