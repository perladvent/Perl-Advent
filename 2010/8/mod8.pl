package Present;
use selfvars;

sub new{
    return bless({}, shift);
}

sub give{
    #Look ma! No shift
    printf "%s to %s\n", $hopts{what}, $hopts{who};
}

package main;

my $gift = new Present;
$gift->give(what=>'Zoozit sticks', who=>'Cindy Lou');
