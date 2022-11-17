#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
use List::Util qw(min);
use XML::Feed;

my @feed_urls;
my $num_entries = 40;
my($output_format, $output_file) = "RSS";
my($subj_filter, $subj_filter_out, $feed_link);

GetOptions(
           'url|u=s@' => \@feed_urls,                   # Sources
           'o=s' => \$output_file,                      # Output file
           'output-format=s' => \$output_format,        # Output type
           'num-entries=i' => \$num_entries,            # Entry limit
           'subject-filter=s' => \$subj_filter,         # Positive filter
           'subject-filter-out=s' => \$subj_filter_out, # Negative filter
           'feed-link=s' => \$feed_link,                # Link location
          );


my $feed                   = XML::Feed->new($output_format) or
  die XML::Feed->errstr;
my $feed_with_less_entries = XML::Feed->new($output_format) or
  die XML::Feed->errstr;
if (!defined($feed_link)) {
  die "The feed's link was not specified!";
}
else {
  $feed_with_less_entries->link($feed_link);
}


# With qr// you can have multiple filters like: foo|bar
foreach my $f ($subj_filter, $subj_filter_out) {
  if (defined($f)) {
    $f = qr/$f/;
  }
}

foreach my $url (@feed_urls) {
  my $url_feed = XML::Feed->parse(URI->new($url))
    or die XML::Feed->errstr;
  $feed->splice(myconvert($url_feed));
}

my @entries = grep
  {
    (defined($subj_filter)     ? ($_->title() =~ /$subj_filter/)     : 1) &&
    (defined($subj_filter_out) ? ($_->title() !~ /$subj_filter_out/) : 1)
  }
  $feed->entries();
@entries = reverse(sort { $a->issued() <=> $b->issued() } @entries);

foreach my $e (@entries[0 .. min($num_entries-1, $#entries)]) {
  $feed_with_less_entries->add_entry($e);
}


my $out;
if ($output_file) {
  open $out, ">", $output_file;
}
else {
  open $out, ">&STDOUT";
}
binmode $out, ":utf8";
print {$out} $feed_with_less_entries->as_xml();
close($out);


sub myconvert{
  my $feed = shift;
  if (
      (($output_format eq "RSS") && ($feed->format() eq "Atom")) ||
      (($output_format eq "Atom") && ($feed->format() ne "Atom"))
     )
  {
    return $feed->convert($output_format);
  }
  else {
    return $feed;
  }
}
