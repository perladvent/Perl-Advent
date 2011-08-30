# Keeping with the spirit of fun there is some slight obfuscation
# and possibly questionable coding practices in an attempt to show off as many
# Set-Array functions as possible. Also there is some questionable grammar.
# The singular form of geese-a-laying surely isn't geese-a-laying is it?
# Healthy pours of some wassail will relieve my mind (and yours) of these
# concerns and induce some holiday cheer... Adam Russell ac.russell@live.com

use Set::Array;  
my @gifts_per_day=();
my @cardinals=qw(first second third fourth
                 fifth sixth seventh eighth
                 ninth tenth eleventh twelfth);
my @gifts=qw(partridge 
             turtle-dove 
             french-hens
             calling-bird
             golden-ring
             geese-a-laying
             swan-a-swimming
             maid-a-milking
             lady-dancing
             lord-a-leaping
             piper-piping
             drummer-drumming);

foreach my $day (1..12){ #the song wins--there is no 0th day of Christmas!
    $gifts_per_day[$day]=Set::Array->new(split(/\s/, "$gifts[$day-1] " x $day));
}

my $total_gifts=Set::Array->new;
my $total_unique_gifts=Set::Array->new;

foreach my $day (1..12){
    my $gifts=gift_calculator($day);
    $total_gifts->bag($gifts); #bag keeps duplicates
    $total_unique_gifts->union($gifts); #union discards duplicates
    print "On the $cardinals[$day-1] of Christmas my true love gave to me the following lovely gifts: ";
    $gifts->join(" ")->print(1);
}

my $total_number_gifts=$total_gifts->length();
my $total_number_geese=$total_gifts->count($gifts[5]);
my $unique_gifts=$total_unique_gifts->length();

print "I received $total_number_gifts gifts!\n";
print "But I only got $unique_gifts different sorts of things...\n";
print "What am I supposed to do with $total_number_geese $gifts[5]? Are they going to eat much?\n";

sub gift_calculator{
    my $todays_gifts=Set::Array->new;
    my $current_day=shift @_;
    foreach my $day (1..$current_day){ #use bag() to bag the gifts!
        $todays_gifts->bag($gifts_per_day[$day]);
    }
    return $todays_gifts;
}
