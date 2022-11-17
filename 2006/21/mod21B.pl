#!/usr/bin/perl
use strict;
use warnings;
use Acme::Santa;

my %list = (
  David      => [ 'White Christmas' ],
  Grinch     => [ 'Christmas Theft' ],
  Satan      => [ 'Fire', 'Brimestome' ],
  'Dr. Evil' => [ 'World Domination' ],
);
my %list2 = (
  David      => [ 'Candy Cane' ],
);

my $Santa = Acme::Santa->new;
$Santa->make_a_list( %list );
$Santa->make_a_list( %list2 );
$Santa->check_it_twice;
$Santa->make_toys;
$Santa->fly_reindeer;
