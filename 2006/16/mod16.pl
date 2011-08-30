#!/usr/bin/perl
#use bignum;
use Number::WithError;

#The answer is 42, but it might be 54
my $x = Number::WithError->new(42, [12, 0]);

#Somewhere's about 7
my $y = Number::WithError->new(7, 2);

printf "x = %s\ny = %s\n\n", $x, $y;
printf "z =  x * y  = %s\n", $z = $x * $y;
printf "w =  x / y  = %s\n", $w = $x / $y;
printf "e = sqrt(y) = %s\n", $e = sqrt($y);
