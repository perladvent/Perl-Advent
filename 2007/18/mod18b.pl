use Acme::Curses::Marquee;
use Curses;
use Text::FIGlet; #For pure-perl portability
use Time::HiRes 'usleep';

#Set height and width of scroll area
use constant {X=>80, Y=>9};

#Start your engines
initscr;

#Create the scrolling area half-way down the standard terminal
#Unfortunately, instantiating it in the marquee maker segfaults
my $w = subwin(Y,X,8,0);

#Make the marquee
my $m = Acme::Curses::Marquee->new( window => $w,
                                    height => Y,
                                    width  => X,
				  );

#Dragons be here
my $font = Text::FIGlet->new(-f=>'gothic',);
$m->{figtxt} = [#Add space between the beginning and the end of the message
		map {$_.=' 'x25}
		#Alas T::F does not produce an array we can expose so we must
		split $/,
		#Extra-wide so it's on one line, otherwise increase subwin Y
		$font->figify(-A=>'Merry Xmas')#, -w=>120)
	       ];
#More twiddling with A::C::M's semi-private bits
$m->{txtlen} = length($m->{figtxt}->[0]);
$m->{active} = 1;

#Wheeeee!
while (1) {
  usleep(75_000);
  $m->scroll;
}
