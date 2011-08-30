#!/usr/bin/perl

use strict;
use warnings;
use LWP::Simple;
use Data::Dumper;

sub get_links {
  my $s = get 'http://perladvent.pm.org/archives-Yd.html';
  my @list;
  foreach my $line (split /[\r\n]+/, $s){
    next unless $line =~ m#(\d+)-(\d+)-(\d+)</a>\s*&mdash;#;
    my ($year,$month,$day,$module) = ($1, $2, $3);
    my @modules = $line =~ m#module=(\S+)"#g or next;
    push @list, { year => $year, day => $day, modules => join(', ',@modules), title => get_title($year,$day) };
  }
  return \@list;
}
sub get_title {
  my ($year,$day) = @_;
  use WWW::Mechanize;
  my $mech = WWW::Mechanize->new;
  $mech->get(sprintf('http://perladvent.pm.org/%d/%d',$year,$day));
  if( $mech->content =~ m#<meta http-equiv="refresh" content="0;url=(.*?)"># ){
    # Handle any "Ordinal Redirects" done via a meta-refresh
    $mech->get($1);
  }
  return $mech->title;

}

my $links = get_links();
print Dumper $links;

