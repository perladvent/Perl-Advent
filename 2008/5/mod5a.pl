use Test::More 'no_plan';

use ChildrenDB;

while ( my $kid = ChildrenDB::next_child() ) {
    my $who = "Li'l " . $kid->name;

    ok $kid->nice_level >= 5,    "$who has been nice";
    ok $kid->eat_vegetables,     "$who ate his/her veggies";
    ok $kid->avg_bedtime < 1930, "$who off to bed before 19:30";
    ok !$kid->been_pouting,      "$who has not been pouting";
    ok !$kid->been_grouchy,      "$who has not been grouchy";
}

