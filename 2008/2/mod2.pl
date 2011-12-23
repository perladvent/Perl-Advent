{   #Cuddled for closure
    use Math::Prime::TiedArray;
    tie my @primes, 'Math::Prime::TiedArray', cache => "primes.dbm";

    sub is_prime {
        my $x = shift;

        if ( $x > $primes[$#primes] ) {

            # $x outside of the range of primes
            # already found

            my $i = 0;
            while (1) {
                my $p = $primes[ $i++ ];    # will magically grow as needed!
                return 1 if $p > sqrt $x;
                return 0 unless $x % $p;
            }
        }

        # $x inside the range of primes already found
        # we try to find it with a binary search

        my $min = 0;
        my $max = $#primes;

        while ( $min <= $max ) {
            my $middle = int $min + ( $max - $min ) / 2;

            # ah AH! found it. it's a prime
            return 1 if $primes[$middle] == $x;

            if ( $primes[$middle] < $x ) {
                $min = $middle + 1;
            }
            else {
                $max = $middle - 1;
            }
        }

        return 0;    # not found in list, so not a prime
    }

}
