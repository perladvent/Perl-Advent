package Acme::Santa;
use strict;
use warnings;

use constant NAUGHTY => 0;
use constant NICE    => 1;

sub new {
  my $self = shift;
  bless { _list=>{} }, $self;
}

sub make_a_list {
  my $self = shift;
  my %list = @_;
  my $ct = 0;
  while( my ($k, $v) = each %list ){
    $ct += @$v;
    $self->{_list}->{$k} ||= [];
    push @{$self->{_list}->{$k}}, @$v;
  }
  return $ct;
}

sub check_it_twice {
  my $self = shift;
  while( my ($who, $list) = each %{$self->{_list}} ){
8     unless ( $self->_is_naughty_or_nice($who) == NICE ){
      $_ = 'coal' for @$list;
    }
  }
}

sub _is_naughty_or_nice {
  my $self = shift;
  my $who = shift;
  if( $who =~ /\bevil\b/i || $who =~ /\bsatan\b/i){
    return NAUGHTY;
  }elsif( $who =~ /\bgrinch\b/i ){
    sleep 1;
    return NAUGHTY;
  }
  return NICE;
}

sub make_toys    { my $self = shift; }
sub fly_reindeer { my $self = shift; }

1;
