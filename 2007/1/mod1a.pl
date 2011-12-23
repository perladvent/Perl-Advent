use Data::ICal;
use Data::ICal::Entry::Event;
use Date::Calc qw/Add_Delta_Days/;

my $calendar = Data::ICal->new();
$calendar->add_properties( 'X-WR-CALNAME' => 'The Twelve Days of Christmas' );

my $song = '';
while(my $line = <DATA>){
  $song = $line . $song;
  chomp($line);
  my $vevent = Data::ICal::Entry::Event->new();
  $vevent->add_properties(
    summary => $line,
    description => "On the 12th day of Christmas, my true love sent to me\n" . $song,
    dtstart => sprintf( '%04d%02d%02d', Add_Delta_Days(2007,12,24,$.) ),
  );
  $calendar->add_entry($vevent);
}

print $calendar->as_string;

__DATA__
A partridge in a pear tree
Two turtle doves
Three French hens
Four calling birds
Five golden rings
Six geese a-laying
Seven swans a-swimming
Eight maids a-milking
Nine ladies dancing
Ten lords a-leaping
Eleven pipers piping
Twelve drummers drumming
