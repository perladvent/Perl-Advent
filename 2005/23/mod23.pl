#! perl -l -w

use strict;
use warnings;
use Carp;
use Sort::Maker;

 open my $NETSTAT, "netstat -a|"
  or die "Netstat fails $@ ";

my %Connections;

while (<$NETSTAT>) {
  my @F=split /\s+/, $_;
  next unless $F[-1] eq 'ESTABLISHED';
  my ($local, $remote)=@F[3..4]; # Slice!

  next if $local =~ /[.:][*]/ or $remote =~ /[*]/;
  my @L=split /[.:]/, $local;
  $remote=~ s/[.:][^.:]+$//;

  $Connections{$remote}->{count}++;



}

package utility;
   { ## Scope for private  var
   use Socket; # for AF_INET, inet_aton
   my $Zeroes=inet_aton("0.0.0.0");

sub key_of {
  my $addr=shift;
  return inet_aton("0.0.0.0") unless defined $addr and $addr;
  my $is_numeric =  $addr =~ /^ ([.\d]+) $/;

  if ($is_numeric)  {
    # my $name = (gethostbyaddr($addr,AF_INET))[0];
    return inet_ntoa($addr);
  }
  else {
    my $num=(gethostbyname($addr))[4];
    return $Zeroes unless $num;
    return $num;
  }

}

} # end  scope block

package main;
use Socket; # for inet_ntoa;

  my $sort_func = 
  make_sorter(
                           plain=>1 ,
                            # name=> 'main::sort_func',
                            string => {
                                      ascending=>1,
                                         unsigned=>1,
                                      code => sub { utility::key_of $_ ;
} ,
                                     },
                          )

  or croak "no sort: $@";


  my $name;
  for $name ($sort_func->(keys %Connections)) {
    my $addr=inet_ntoa(utility::key_of ($name));
    print "$Connections{$name}->{count}\t$name\t$addr";

  }
