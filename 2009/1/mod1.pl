package Reindeer;
use Any::Moose::Forcefully; #All Mooses are Mouses
use Moose;

has 'name'  => (is=>'ro', isa=>'Str',  default=>'Comet');
has 'sound' => (is=>'ro', isa=>'Str',  default=>'');
has 'flies' => (is=>'ro', isa=>'Bool', default=>1);

sub stats {
    my ($self) = @_;
    printf("%s %s, and goes '%s.'\n",
	   $self->name(),
	   ($self->flies ? 'flies' : 'does not fly'),
	   $self->sound());
}

1;

package main;
use Data::Dumper;
import Reindeer; #not use, package is in the same file

my $Olive = Reindeer->new(flies=>0, name=>'Olive', sound=>'woof');
my $Comet = Reindeer->new();

$Olive->stats();
$Comet->stats();

print "\n", Dumper \%INC;
