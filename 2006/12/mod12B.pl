#!/usr/bin/perl

=head1 NAME 

my_script.pl

=head1 REQUIRED ARGUMENTS

=over 8

=item -f[ile] [=] <filename> 

The filename to be used as input.  

=back

=head1 OPTIONAL ARGUMENTS

=over 8

=item -v[erbose]

Print verbose output as the script runs. 
Can be used more than once to increase the verbosity.

=for Euclid:
    repeatable

=back

=head1 BUGS

None known at this time

=cut

use Getopt::Euclid;
use Data::Dumper;

print "I got the following options:
@{[ Dumper \%ARGV ]}
" if $ARGV{-verbose}->[0];
