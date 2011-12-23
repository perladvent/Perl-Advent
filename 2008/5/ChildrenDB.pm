package ChildrenDB;

use strict;
use warnings;

# mock-up of the North Pole children database
# which can't be reproduced here (as it's top-secret
# material)

my @children = (
    Kid->new( name => 'Timmy' ),
    Kid->new( name => 'Dennis', nice_level => 2, eat_vegetables => 0, ),
    Kid->new( name => 'Linus' ),
    Kid->new( name => 'Lucy', been_grouchy => 1 ),
);

sub next_child {
    return shift @children;
}

{

    package Kid;

    sub new {
        my ( $class, %attrs ) = @_;

        return bless {
            nice_level     => 5,
            eat_vegetables => 1,
            avg_bedtime    => 1900,
            been_pouting   => 0,
            been_grouchy   => 0,
            %attrs,
        }, $class;

    }

    sub AUTOLOAD {
        no strict;
        ( my $key = $AUTOLOAD ) =~ s/^.*:://;
        return $_[0]->{$key};
    }
}

1;
