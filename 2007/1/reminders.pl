use Data::ICal;
use Data::ICal::Entry::Event;

my $vevent = Data::ICal::Entry::Event->new();
$vevent->add_properties(
  summary => 'Hooray! New Perl Advent Entry',
  description => 'Refresh the RSS reader with baited breath',
  url => 'http://perladvent.org/2007',
  dtstart => '20071201',
  rrule => 'FREQ=DAILY;UNTIL=20071224',
);

my $calendar = Data::ICal->new();
$calendar->add_entry($vevent);
(my $s = $calendar->as_string) =~ s/\\//g;
print $s;
