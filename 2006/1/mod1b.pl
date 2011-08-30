#!/usr/bin/perl
my $COUNT = 5; #Orders of magnitude
my $HIT = 0;

for(my $i = 1; $i < 10**$COUNT; ++$i){
  $HIT++ if rand()**2 + rand()**2 <= 1;

  printf "PI ~ %1.8f after %0${COUNT}i points\n", 4*$HIT/$i, $i if
    ($i % 1_000) == 0;
}
