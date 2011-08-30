use Data::COW;
use Data::Dumper; #No jokes about buffalo biscuits please

my $struct = {
	      fib=>[1,1,2,3],	      
	      b1f=>'I like meat!'
	     };

print Data::Dumper->Dump([$struct], ['struct']);

print "Make changes here...\n";
my $calf = make_cow_ref $struct;
push @{$calf->{fib}}, 5, 8, 13;

print Data::Dumper->Dump([$calf], ['calf']);


print Data::Dumper->Dump([$struct, $calf], [qw'struct calf']);

#Okay fine, but a deep copy would look the same...
#...but references would be different, even for unmodified values
print "Eat more chickin\n" if $struct->{b1f} eq $calf->{b1f};
