use File::ReadBackwards;

$bw = File::ReadBackwards->new('nice.txt')
  or die "can't read nice file $!";

while ( defined( $log_line = $bw->readline ) ) {
    print $log_line;
}
