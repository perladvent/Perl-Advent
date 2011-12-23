#!/usr/bin/perl

=head1 NAME 

my_script.pl

=head1 SYNOPSIS

 my_script.pl [-v] -f <filename>

=head1 OPTIONS

=over 8

=item B<-f> or B<--file> <filename> (required)

The filename to be used as input.  Required.

=item B<-h> or B<--help>

Print a brief help message and exits.

=item B<-v> or B<--verbose>

Print verbose output as the script runs. 
Can be used more than once to increase the verbosity.

=back

=head1 BUGS

None known at this time

=cut
use Pod::Usage qw/ pod2usage /;
use Getopt::Long qw/ GetOptions /;

GetOptions( 'file=s'   => \(my $file),
            'verbose+' => \(my $verbose),
            'help'     => \(my $help),
          );

pod2usage(-verbose => $verbose) if $help;

pod2usage( -message => '--filename required',
           -exitval => 1,
           -verbose => $verbose,
) unless defined $file;



print "I got the following options:
file:    $file
verbose: $verbose
" if $verbose;
