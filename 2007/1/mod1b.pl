use Data::ICal;
use Data::ICal::Entry::Event;

my $links_file = $ARGV[0] or die;

my $calendar = Data::ICal->new();
$calendar->add_properties(
  'X-WR-CALNAME' => 'Perl Advent Calendar',
  'X-WR-CALDESC' => 'Perl Advent Calendar history - http://perladvent.pm.org/',
);

my $links = do {local $/=undef; open FILE, '<', $links_file or die; my $VAR1; eval <FILE>};

foreach my $row ( @$links ){
    my $vevent = Data::ICal::Entry::Event->new();
    $vevent->add_properties(
          summary => $row->{modules},
	  description => $row->{title},
          categories => 'Perl Advent Calendar',
	  dtstart => sprintf('%04d%02d%02d',$row->{year},12,$row->{day}),
	  url => sprintf('http://perladvent.pm.org/%d/%d/',$row->{year},$row->{day}),
    );
    $calendar->add_entry($vevent);
}

print $calendar->as_string;
