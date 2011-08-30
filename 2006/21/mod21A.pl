#!/usr/bin/perl
use strict;
use warnings;
use Acme::Santa;

my %list = ( David => [ 'White Christmas', 'Candy Cane' ] );
my $Santa = Acme::Santa->new();
$Santa->make_a_list( %list );
$Santa->check_it_twice;
