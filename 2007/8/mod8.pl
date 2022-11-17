use Math::Combinatorics;
use List::Util qw/shuffle first/;

#               0      1      2     3     4      5
my @set = qw/ Dasher Dancer Comet Cupid Donner Blitzen /;

my $N = scalar @set;
my @exclude = (
  [ 4 => 1 ], # Donner => 'Dancer'
  [ 2 => 3 ], # Comet  => 'Cupid'
  [ 3 => 2 ], # Cupid  => 'Comet'
);

my %exceptions = map { my ($r,$c) = @$_; $r*$N+$c => undef } @exclude;
my $combinat = Math::Combinatorics->new(
  count => $N,
  data => [shuffle grep { int($_/$N)!=$_%$N && ! exists $exceptions{$_} } 0 .. $N*$N-1]
);

my (%givers, %recips);
my $ct=0;
my $numItems = $N*$N-$N-scalar(keys %exceptions);
printf "There are C(%d,%d) = %.f total combinations.\n",
	$numItems, $N,
	factorial($numItems)/factorial($numItems-$N)/factorial($N);
while(my @combo = $combinat->next_combination){
  $ct++;
  %givers = map { int($_/$N) => $_%$N } @combo;
  @recips{values %givers} = keys %givers;  # invert hash
  do{ %givers=(); next } if
    keys(%givers) != $N
    || keys(%recips) != $N
  ;
  last;
}
print "Tried $ct combinations.\n";
die "no valid combination exists" unless %givers;

printf "%s => %s\n", @set[ $_, $givers{$_} ] for keys %givers;
