# Let's make some ascii bar charts! 
# Adam Russell ac.russell@live.com

use Text::BarGraph;

my(%naught_nice, $total);
my $graph = Text::BarGraph->new();
while (my $line = <DATA>) {
    chomp $line;
    my @fields=split(/:/,$line);
    $total += $naught_nice{$fields[0]}=$fields[1];
}
$graph->dot("*");
$graph->enable_color(1);
$graph->max_data($total);
$graph->sortvalue("data");
print $graph->graph(\%naught_nice);

__DATA__
naughty:233314664
nice:456089984
unknown:129398430
