#!/usr/bin/perl -w                                                       
use strict;                                                              
use vars '$VERSION';                                                     
use File::Spec;                                                          

$VERSION = 0.03;

foreach my $PM ( @ARGV ){
  eval "require $PM" || next;
  $PM = File::Spec->catfile(split(/::/, $PM));
  $PM .= '.pm' unless $PM =~ /\.pm$/;         
  print $INC{$PM}, ' ';                       
}                                             
print "\n";                                   
__END__                                       

=pod

=head1 NAME

whichpm - lists real paths of specified modules

=head1 SYNOPSIS

  less `whichpm Bar`

=head1 DESCRIPTION

Analogous to the UN*X command which.

Even with TAB completion entering paths like
F</afs/athena.mit.edu/user/u/s/user/lib/perl5/site_perl/5.8.0/IO/Pager>
can be gruesome. ~ makes it a bit more bearable
F<~/lib/perl5/site_perl/5.8.0/IO/Pager>.
Then inspiration struck, perl knows where its libraries are; modulo @INC.
Better yet, you don't have to know if it's a core module or site specific
nor architecture specific vs. platform independent.

=head1 AUTHOR

Jerrad Pierce <jpierce@cpan.org>

=cut
