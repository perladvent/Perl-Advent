package mod17;

use strict;
use warnings;
use base qw(Pod::Simple);
use Perl::Tidy;

our @mode;
our $section = '';
our %data = (
  title => undef,
  author => undef,
  year => (localtime)[5]+1900,
  day => 0,
  body => '',
);

sub new {
  my $self = shift;
  $self = $self->SUPER::new(@_);
  $self->accept_codes( qw/A M N/ );
  $self->accept_targets_as_text( qw/advent_title advent_author advent_year advent_day/ );
  $self->accept_targets( qw/eds/ );
  $self->accept_directive_as_data('sourcedcode');
  return $self;
}

sub add {
  my $self = shift;
  $data{body} .= $_[0];
}

sub br { shift->add("\n") }

sub _handle_element_start {
  my($parser, $element_name, $attr_hash_r) = @_;
  push @mode, $element_name;
  if( $element_name eq 'Document' ){
  }elsif( $element_name =~ /^head([1-4])$/ ){
    $parser->add("<h$1>");
  }elsif( $element_name eq 'Para' ){
    $parser->add('<p>');
  }elsif( $element_name =~ /^(M|F|C)$/ ){
    $parser->add('<tt>');
  }elsif( $element_name =~ /^(I|B)$/ ){
    $parser->add("<$1>");
  }elsif( $element_name eq 'for' && $attr_hash_r->{target} =~ /^advent_(\w+)$/ ){
    $section = $1;
  }elsif( $element_name eq 'for' && $attr_hash_r->{target} eq 'eds' ){
    $mode[-1] = $attr_hash_r->{target};
    $parser->add('<blockquote style="padding: 1em; border: 2px ridge black; background-color:#eee">');
  }
}

sub _handle_element_end {
  my($parser, $element_name) = @_;
  my $mode = pop @mode;
  if( $element_name eq 'Document' ){
    $parser->br;
    $parser->add('</body>');
    $parser->br;
    $parser->add('</html>');
    $parser->br;

    printf <<'EOF', @data{qw/year title year day title author/};
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>%d Perl Advent Calendar: %s</title>
<link rel="stylesheet" href="../style.css" type="text/css" /></head>
<body>
<h1><a href="../">Perl Advent Calendar %d-12</a>-%02d</h1>
<h2 align="center">%s</h2>
<h3 align="center">by %s</h3>
EOF
    print $data{body};
</html>
  }elsif( $element_name =~ /^head([1-4])$/ ){
    $parser->add("</h$1>");
    $parser->br;
  }elsif( $element_name eq 'Para' ){
    $parser->add('</p>');
    $parser->br;
  }elsif( $element_name eq 'for' && $mode eq 'eds' ){
    $parser->add('</blockquote>');
    $parser->br;
  }elsif( $element_name =~ /^(M|F|C)$/ ){
    $parser->add('</tt>');
  }elsif( $element_name =~ /^(I|B)$/ ){
    $parser->add("</$1>");
  }
}

sub _handle_text {
  my($parser, $text) = @_;
  my $mode = $mode[-1];
  my $out = '';
  if( $mode eq 'Verbatim' || $mode eq 'C' ){
    my $s;
    Perl::Tidy::perltidy(
        source            => \$text,
        destination       => \$s,
        argv              => [qw/-html -pre/],
    );
    $s =~ s#^<pre>\s*(.*?)\s*</pre>$#$1#si if $mode eq 'C';
    $out .= $s;
  }elsif( $mode eq 'sourcedcode' ){
    die "bad filename $text " unless -r $text;
    $out .= sprintf '<a name="%s"></a><h2><a href="%s">%s</a></h2>', ($text)x3;
    my $s;
    Perl::Tidy::perltidy(
        source            => $text,
        destination       => \$s,
        argv              => [qw/-html -pre -nnn/],
    );
    $out .= $s;
  }elsif( $mode eq 'Para' && $section ){
    $data{$section} = $text;
    $section = '';
  }elsif( $mode eq 'A' ){
    my ($href, $text) = split /\|/, $text, 2;
    $text = $href unless defined $text;
    $parser->add( sprintf('<tt><a href="%s">%s</a></tt>',$href,$text) );
  }elsif( $mode eq 'M' ){
    $parser->add( sprintf('<a href="http://search.cpan.org/search?query=%s">%s</a>',$text,$text) );
  }elsif( $mode eq 'N' ){
    $out .= sprintf '<sup><a href="#%s">%s</a></sup>', $text, $text;
  }else{
    $out .= $text;
  }
  $parser->add( $out, undef );
}
1;
