#!/usr/bin/perl
my $COUNT = 5; #Orders of magnitude
my $HIT = 0;

for(my $i = 1; $i < 10**$COUNT; ++$i){
  my $x = rand();
  my $y = rand();

  #The equals condition is neglected in many implementations
  if( ($x**2 + $y**2) <= 1 ){
    $HIT++;
  }

  #Multiply by 4 as we're using a single quadrant
  printf "PI ~ %1.8f after %0${COUNT}i points\n", 4*$HIT/$i, $i if
    ($i % 1_000) == 0;
}
