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
