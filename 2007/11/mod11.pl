#lifted from perlthrtut
use forks;

sub loop {
        my $thread = shift;
        my $foo = 50;
        while($foo--) { print "in thread $thread\n" }
        threads->yield;
        $foo = 50;
        while($foo--) { print "in thread $thread\n" }
}

my $thread1 = threads->new(\&loop, 'first');
my $thread2 = threads->new(\&loop, 'second');
my $thread3 = threads->new(\&loop, 'third');
