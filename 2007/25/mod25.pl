#This game is not playable on Win32 due to blocking I/O
INIT{ $| = 1 }

use Time::Out 'timeout';
use Search::Dict;

#Time to play, time per word
my($tt, $tw, %words, %yet) = (60, 3);
#Word list
my $dict = '/usr/share/dict/words';

#Isolate sleep from alarm for cheesy async timer
if( fork ){
    &timer;
}
else{
    %yet = map{ $_=>0 } a..z;
    timeout $tt => \&wrapper;
    printf "\n\nTotal score, %i\n", score();
}

sub wrapper{
    for(my $i=0; $i<26; $i++){
	printf "\nletter? [%s]", join('', sort keys %yet);

	my $l = substr(lc(<STDIN>), 0, 1);

	#Funky syntax if you want to pass args
	timeout($tw => $l, \&word) if
	    #Alpha only, no retries
	    $l =~ /\w/ && exists($yet{$l});
    }
}

sub word{
    my $l = shift;

    print "word? ";
    chomp( my $w = <STDIN> );

    return unless substr($w, 0, 1) eq $l;
    $words{$l} = $w;	
    delete($yet{$l});
}


#Supporting routines
sub timer{
    return unless $tt;
    printf "\r%s%02i ", "\t"x5, --$tt;
    sleep 1;
    &timer;
}

sub score{
    my $ts = 0;
    open(my $dict, $dict);

    print "\n";

    while( my($k, $v) = each %words ){
	print "\n$v... ";

	my($ws, $bogus) = (0, 0);
	$ws = length $v;
	$ws *= eval "$v =~ y/$k//";

	$bogus = look($dict, $v, 1, 1) < 0 ? 1 :
	    (chomp($_=readline($dict)), $_) ne $v;

	if( $bogus ){
	    print STDERR "not found, deducting $ws";
	    $ws *= -1;
	}
	else{
	    print STDERR "is valid, awarding $ws";
	}
	$ts += $ws;
    }
    return $ts;
}
