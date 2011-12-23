use Parallel::Jobs;

my @orders = (
    [ 'amazonia.txt'   => 'snick@amazonia.com:orders/' ],
    [ 'sprawlmart.csv' => 'claus@sprawlmart.com:cheap_stuff/' ],
    [ 'priceco.xml'    => 'santa@priceco.com:bulk_buys/' ],
);

my %placed_orders;

for my $order (@orders) {
    $placed_orders{ Parallel::Jobs::start_job( 'scp', @$order ) } =
      $order->[0];
}

while ( my ( $pid, $event, $data ) = Parallel::Jobs::watch_jobs() ) {
    if ( $event eq 'EXIT' ) {
        if ( !$data ) {
            print "Transferred $placed_orders{$pid}\n";
        }
        else {
            print "Failed to transfer $placed_orders{$pid}\n";
        }
        delete $placed_orders{$pid};
    }
}
use warnings;
use strict;
use Parallel::Jobs;

my $nice_pid =
  Parallel::Jobs::start_job(
    { stdin_file => 'nice.txt', stdout_capture => 1, stderr_capture => 1 },
    'wc', '-l' );

print "NICE [$nice_pid]\n";

sleep(1);

open( NAUGHTY,     '<', 'naughty.txt' ) or die $!;
open( NAUGHTY_OUT, '>', 'naughty.out' ) or die $!;
open( NAUGHTY_ERR, '>', 'naughty.err' ) or die $!;

my $naughty_pid = Parallel::Jobs::start_job(
    {
        stdin_handle  => *NAUGHTY,
        stdout_handle => *NAUGHTY_OUT,
        stderr_handle => *NAUGHTY_ERR
    },
    'wc', '-l'
);

print "NOT NICE [$naughty_pid]\n";

while ( my ( $pid, $event, $data ) = Parallel::Jobs::watch_jobs() ) {
    print "Finished [$pid] [$event] [$data]\n";
}

close NAUGHTY;
