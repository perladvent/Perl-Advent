#!/usr/bin/perl -l

use strict;
use warnings;

use lib( ".." );
use Treemap::Squarified;
use Treemap::Input::XML;
use Treemap::Output::Imager;

use Getopt::Long;
use Pod::Usage;
my ($verbose,$help, $man);

my ($padding, $spacing)=(5,5); 
my ($fontdir, $font,$font_color)=(undef,'ImUgly','#000000'); ## 00=>Black
my $fontfile;
my $outfile;
my $outtype="png";
my $infile;
my ($width,$height)=(800,600); # Fullscreen on small projector good default?

my $result = GetOptions (
         "padding=i" => \$padding,        # numeric
         "spacing=i" => \$spacing,        # numeric
        # "length=i" => \$length,         # numeric
        # "file=s"   => \$data,           # string
          "infile=s" => \$infile,         # string
          "outfile=s"=> \$outfile,        # string
          "outtype=s"=> \$outfile,        # string
          "fontdir=s"=> \$fontdir,        # string
          "font=s"   => \$font,           # string
          "fontfile=s"=> \$fontfile,      # string
          "fontcolor=s"   => \$font_color,# string

          "verbose|v|V"   => \$verbose,   # flag
           'help|h|?'     => \$help, 
           man            => \$man,
        ) or pod2usage(2);
           pod2usage(1) if $help;
           pod2usage(-exitstatus => 0, -verbose => 2) if $man;

### TBD - could add a couple more options ...
# BORDER_COLOUR MIN_FONT_SIZE TEXT_DEBUG DEBUG
## Will also need to pass args to a CSV input parser ...
##


# Default cascades
$infile ||= shift || "XML.xml";
print "infile=>$infile" if $verbose;

$outfile ||= shift || "$infile.$outtype";
print "outfile=>$outfile" if $verbose;

if ($font && ! $fontfile && ! $fontdir) 
{
   my @fonts = grep { -f $_} map {"$_/$font.ttf"} (glob('~/.fonts'),glob('~/.fonts/*'),glob('/usr/share/fonts/*'));
   $fontfile = pop @fonts || (warn "No matching font in .font or /usr/share/fonts")&&'';
} 

$fontfile ||= "$fontdir/$font.ttf" if $font && $fontdir;
$fontfile ||= '../ImUgly.ttf';
print "font=>$fontfile" if $verbose;

print "$width x $height ($padding, $spacing)" if $verbose;

## Input
#
my $input = new Treemap::Input::XML; ## @TBD -- suggested autoloading Input type, output type?
print "Loading $infile...\n";
$input->load( $infile );

## Output
#
my $output = new Treemap::Output::Imager( WIDTH=>$width, HEIGHT=>$height,
        FONT_FILE=>$fontfile,
        FONT_COLOUR=>$font_color,
        );

## Splice them together with Layout object
#
my $treemap = new Treemap::Squarified( INPUT=>$input, OUTPUT=>$output,
        PADDING=>$padding, 
        SPACING=>$spacing, 
        );

## Do it
#
$treemap->map();
$output->save($outfile);

## Done!
__END__

=head1 mod03.pl Generic TreeMap Script, mk 1

sample

=head1 SYNOPSIS

$0 [args] [infile] [outfile]

Options:

  -help         brief help
  -man          full doc
  -verbose      any trace capabilites in script, maybe none
  -padding=5    interior space colored with parent node color; if 0, parent node colors vanish.
  -spacing=5    exterior space colored with background color; if 0, squares split only by bkgcolor line.
  -fontfile=../ImUgly.ttf  A font to use, can be used instead of next two or default
  -font=arial    name of font to use, use with ...
  -fontdir=/usr/share/fonts/corefonts  where to find fonts (with above)
  -fontcolor='#RRGGBB' Font color in pseudo-html rgb numeric string

=head1 COPYRIGHT

Copyright Bill Ricker 2006, based on Treemap examples.
This program is free software, to be used under the same terms are Perl itself.

=cut
  
