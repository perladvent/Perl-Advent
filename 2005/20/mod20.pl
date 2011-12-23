use Perl::Compare;

my $diff = Perl::Compare->new(from=>'Wubbulous-1.04');

print $diff->compare_report('Wubbulous-1.11');
