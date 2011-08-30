use bignum;
use Interpolation commify=>commify;

print "Straight up\n";
print 4**4000, "\n";
#=Lotsa numbers

print "\nNow slightly more legible\n";
{
  $_ = $commify{4**4000};
  y/,/_/;
  print $_, "\n";
  #=Inf
}

#Doh!
{
  print "\nNow slightly more legible\n";
  $_ = 4**4000;

  #Body of Interpolation::commify
  1 while s/^(-?\d+)(\d{3})/$1,$2/;

  y/,/_/;	    
  print $_, "\n";
  #=The beginning of this page
}
