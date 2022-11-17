use LWP::Simple;
use Data::ICal;
use Data::ICal::Entry::Event;

my $YEAR = shift or die "need year";

sub get_links {
  my $s = get 'http://perladvent.pm.org/archives-Yd.html';
  my @list;
  foreach my $line (split /[\r\n]+/, $s){
    next unless $line =~ m#(\d+)-(\d+)-(\d+)</a>\s*&mdash;#;
    my ($year,$month,$day,$module) = ($1, $2, $3);
    next unless $year == $YEAR;
    my @modules = $line =~ m#module=(\S+)"#g or next;
    push @list, { year => $year, day => $day, modules => join(', ',@modules), title => get_title($year,$day) };
  }
  return \@list;
}
sub get_title {
  my ($year,$day) = @_;
  use WWW::Mechanize;
  my $mech = WWW::Mechanize->new;
  $mech->get(sprintf('http://perladvent.pm.org/%d/%d',$year,$day));
  if( $mech->content =~ m#<meta http-equiv="refresh" content="0;url=(.*?)"># ){
    # Handle any "Ordinal Redirects" done via a meta-refresh
    $mech->get($1);
  }
  return $mech->title;
}

my $links = get_links();
die "nothing found" unless @$links;

my $calendar = Data::ICal->new();
$calendar->add_properties(
  'X-WR-CALNAME' => "Perl Advent Calendar $YEAR",
  'X-WR-CALDESC' => "Perl Advent Calendar $YEAR - http://perladvent.pm.org/$YEAR/",
);

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
