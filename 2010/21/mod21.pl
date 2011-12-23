use Benchmark::Timer;

my $T = Benchmark::Timer->new( confidence=>95, error=>5, minimum=>2 );

while( $T->need_more_samples('factorial') ){
  $T->start('factorial');
  factorial($_) foreach 0..123;
  $T->stop('factorial');
}

print $T->report;

sub factorial{
  $_[0] > 1 ? $_[0] * factorial($_[0]-1) : 1;
}
