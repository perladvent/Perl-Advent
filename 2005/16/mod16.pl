#! /usr/bin/env perl
use warnings;
use strict;
use Carp;

sub utility::get_title;

# A complete screen-scraper and RSS generator 
# adapted from XML::RSS::SimpleGen POD

use strict;
use XML::RSS::SimpleGen;
my $url = q<http://web.mit.edu/belg4mit/www/>;

rss_new( $url, "YAPAC", "Yet Another Perl (Advent) Calendar" );
rss_language( 'en' );
rss_webmaster( 'jpierce@cpan.org' );
# image is not supposed to be a favicon, but a GIF, skip for now.
# rss_image("http://yourpath.com/icon.gif",32,32);
rss_daily();

get_url( $url );
my @pages;  # List of things to process

while(
      # was
      #  m{<h4>\s*<a href='/(.*?)'.*?>(.*?)</a>\s*</h4>\s*<p.*?>(.*?)<a href='/}sg
      # now must match
      # <br><div><a href="10/" style="left: 375px; top: 255px;">10</a></div>
      
      m{<div> \s* <a \s href="(\d+/)" [^>]* > ([^<>]*) </a> \s* </div> }xisg
      
     ) {
  
  my ($page, $linkText, $title)=($1,$2, undef); #$3 is empty
  
  # Defer with agenda
  push @pages, {page=>$page, link=>$linkText, title=>$title};
}

# now work the agenda, once we've finished the previous parse.
for my $pageRef (@pages) {
  my ($page, $link, $title)=(@$pageRef{qw{page link title}});
  $title ||= utility::get_title($page) || "YA Perl Advent Calendar 2005: ???";
  print "$page $link '$title' \n";
  rss_item("$url$page", $link, $title ) ;
}


croak "No items in this content?! {{\n$_\n}}\nAborting"
  unless rss_item_count();
  
rss_save( 'yapac-rss.xml', 45 );
print "success\n";

exit;

### Reuse HTML::HeadParser from day 5
package utility;
use LWP::Simple;
use HTML::HeadParser;
use Carp;

# not safe for mod_perl ...

sub get_title {
  my $header = HTML::HeadParser->new();
  my $date = shift || croak "get_title requires arg of page name";
  
  my $content = get( $_ = "http://web.mit.edu/belg4mit/www/$date");

  unless( $content ) {
    warn("No content for: $_\n");
    return;
  }
  
  $header->parse($content);
  return $header->header('Title');
}
