# Whatever does this code do?
# Adam Russell ac.russell@live.com
use Whatever; 

$add_2 = 2 + $*; # A typical example of currying   
print "\$* \$add_2->(5)=",$add_2->(5),"\n";

$add_2 = 2 + &*; # Same example with &*   
print "&* \$add_2->(5)=",$add_2->(5),"\n";

#Can be used with map()
@test_data=(0,1,2,3,4,5,6,7,8,9);
@test_data_plus_2=map ($add_2->($_), @test_data);
$with_2_added=join ',',@test_data_plus_2;
print "test_data_array_plus_2 $with_2_added\n";

# A more complex example. Uses multiple whatever-star terms
@test_data=(0,1,2,3,4,5,6,7,8,9);
$sum=&*;
foreach (0..($#test_data-1)){
    $sum=$sum + &*;
}
$a=$sum->(@test_data);
print "sum ","$a\n";

# star terms bind lazily. This allows us to change a variable between calls
$mod=0;
my $filter=(($* % 2) == $mod);
# filter evens
@evens = grep($filter->($_),@test_data);  
print "evens ",join(' ',@evens),"\n";
# filter odds
$mod=1;
@odds=grep($filter->($_),@test_data); 
print "odds  ",join(' ',@odds),"\n";

# Finally, whatever-stars can be used to dereference a hash or array
%test_hash=(0,=>"zero", 1=>"one", 2=>"two");
$val_2=$*->{2};
$val=$val_2->(\%test_hash);
print "val  ",$val,"\n";