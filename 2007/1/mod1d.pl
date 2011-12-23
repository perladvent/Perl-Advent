use Data::ICal;
my $calendar = Data::ICal->new( filename => $ARGV[0] );

print '<h1>', $calendar->property('x-wr-calname')->[0]->value, '</h1>';
print '<h2>', $calendar->property('x-wr-caldesc')->[0]->value, '</h2>';

foreach my $entry ( @{$calendar->entries} ){
  printf '<b>%s</b> - <a href="%s">%s</a> <i>%s</i><br>'."\n",
    map { $entry->property($_)->[0]->value }
    qw/ dtstart url summary description /
  ;
}
