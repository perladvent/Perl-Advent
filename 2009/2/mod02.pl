#! perl -ls

use Tie::CharArray qw/chars codes/;
use List::Util qw/reduce max/;
use List::MoreUtils qw/pairwise/;

my $m        = $count || shift || 3;
my $filename = $fn    || shift || "enable1.txt";
$length ||= 2 * $m;    ## Strictly puzzle  calls for eq 9

open my $DICT, $filename or die "file open $filename $! ";

while (<$DICT>) {
    chop while /\s/;
    next if length() < $length or /^[A-Za]/ or /\W/;    #impossible
    my @N  = codes($_); 
    my @RN = reverse @N;

    my $match = (
        reduce {
            !$a->[-1]
              ? $a
              : [ $a->[0] + $b, $b ];
        }
        [ 0, 1 ],    # inject total zero, continue one
        pairwise { ( $a - $b ) == 1 } @N,
        @RN
    )->[0];

    print "$match $_" if $match >= $m;

}
close DICT;

