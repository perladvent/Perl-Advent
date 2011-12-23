#! perl -lw

use warnings;
use strict;

# require Math::BigApprox;
use Math::BigApprox qw( c Prod );

# Pi -
# if it was BigFloat, I'd use
# 3.14159_26535_89793_23846_26433_83279_50288_41971_69399;
# but with Math::BigApprox
my $pi = c( 355 / 113 ); # is good enough, better than 22/7, better than 3.14159

# oddly,
#  $pi = c(sqrt sqrt (9**2 + 19**2/22)); # is also as good.  http://xkcd.com/217/
# http://use.perl.org/~n1vux/journal/32292
# http://use.perl.org/~n1vux/journal/32686

# Factorial -
# Override Factorial if Stirling approximation good enough

sub Stirling {

    # Stirlings approximate formula for Factorial
    # http://en.wikipedia.org/wiki/Stirling%27s_formula
    my $x = shift;
    my $n = ref $x eq "Math::BigApprox" ? $x : c($x);
    return sqrt( 2 * $pi * $n ) * ( $n / exp(1) )**$n;
}

sub Fact { return $_[0] > 1e4 ? Stirling shift : Math::BigApprox::Fact shift; }

# -----------------------

my $children = c( 2.106 * 10**9 );    # billion children aged under 18  UNICEF

#when? update?
printf "%e %s\n", $children, q{children per unicef};

my $houses = $children / 2.5;         #Assume there are 2.5 children a house

printf "%e stops (children/2.5)\n",
  $houses;                            # 842 million stops on Christmas Eve

printf "%e %s\n", $pi, q{pi};

my $radius = c(3_986);                # earth, miles
printf "%e %s\n", $radius, q{Re Earth radius, miles. };

my $area = ( $radius**2 ) * $pi * 4;
printf "%e %s\n", $area, q{area sq. miles. };

$area = $area * 0.29;                 # % dry

printf "%e %s\n", $area, q{populated area (dry 29%) sq. miles. };
$area = $area / $houses;
printf "%e %s\n", $area, q{area each, sq.miles / houses};

my $distPer = sqrt $area;

printf "%e %s\n", $distPer, q{mean distance, miles (sqrt area each)};

my $dist = $distPer * $houses;

printf "%e %s\n", $dist, q{mileage= houses * mean distance; miles};

my $time = c(48)    # hours IDL to IDL
  * 60 * 60;        # sec
printf "%e %s\n", $time, q{seconds total flight};    #

my $timePer = $time / $houses;                       #s
printf "%e %s\n", $timePer, q{Time between each, s}; #

my $speed = $dist / $time;                           #mi p s

printf "%e %s\n", $speed, q{speed avg, miles/second};    #

my $milePerMetre = 1 / (
    5_280                                                # ft/mi
      * 12                                               # in/ft
      * 2.54                                             # cm/in
      * 1 / 100                                          # m/cm
  )                                                      # 1/(m/mi) = mi/m
  ;

my $speedMetric = $speed / $milePerMetre;                # mps

$speed = $speed * 3600;                                  #MPH

printf "%e %s\n", $speed, q{speed avg, miles/hr};
printf "%e %s\n", $speed, q{speed avg, m/s (metric)};

printf "%e %s\n", $speed / 750, q{Mach - web page off x1000 !};

# web page slipped 3 decimals here !!

my $C = 3E8;    # speed of light, metric, mps
printf "%e %s\n", $C, q{C, speed of light, metric, m/s};
printf "%e %s\n", 1 / ( $speedMetric / $C ),
  q{ratio C:spd :: _:1};    # speed/C, in mps

#########
# acceleration
# Article is off by at least a factor of two here, must accell and then decell.
# to average S, must accelerate to twice that and brake just as hard.

# Real math is
# R = 0.5 a*t**2. in this case,
# R = 2 * (0.5 a* (dt/2)**2)
# $dist = $a (timePer/2)**2

my $accell = $distPer /     # miles
  (
    $milePerMetre * ( ( $timePer / 2 )**2 )    # s.s
  );
printf "%e %s\n", $accell, q{acceleration m/s/s};

my $g = c(9.8);                                # g=9.8m/s/s at surface
printf "%e %s\n", $accell / $g, q{accel G's};

##########
#  Cargo

my $Cargo = ( 2 / 2.2 )                        # kg
  * $children;
printf "%e %s\n", $Cargo * 1000, q{Cargo grams};
printf "%e %s\n", $Cargo * 2.2,  q{Cargo Lbs (2 Lbs/Child)};

printf "%e %s\n", $Cargo * $accell, q{F=ma: Force, Newtons};

# work
# food callories / 12 reindeer

print Fact($houses), q{ traveling salesman, houses!};

# printf "%e %s\n", c(1) << 31, q{2^31 for comparison};
# 2.147484e+09 2^31 for comparison
# use POSIX qw(FLT_MAX DBL_MAX);
# printf "%e %s\n", DBL_MAX, q{DBL_MAX for comparison};
# 1.797693e+308 DBL_MAX for comparison
# printf "%e %s\n", FLT_MAX, q{FLT_MAX for comparison};
# 3.402823e+38 FLT_MAX for comparison

