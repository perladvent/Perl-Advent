use Test::More 'no_plan';

use ChildrenDB;

use Test::Group;

sub been_good($) {
    my $kid = shift;
    test "Li'l " . $kid->name => sub {
        ok $kid->nice_level >= 5,    'has been nice';
        ok $kid->eat_vegetables,     'ate his/her veggies';
        ok $kid->avg_bedtime < 1930, 'off to bed before 19:30';
        ok !$kid->been_pouting,      'not been pouting';
        ok !$kid->been_grouchy,      'not been grouchy';
      }
}

while ( my $kid = ChildrenDB::next_child() ) {
    been_good $kid;
}
