use Sub::Curry qw/ :CONST curry /;

my $fn = sub {
  my @lines = map { "\t" . $_ } @_;
  my @nums = qw/ first second third fourth fifth sixth seventh eighth nineth tenth eleventh twelfth /;
  $lines[-1] =~ s/\t\s*/\tand / if @lines > 1; # grammatical hack
  print "On the " . $nums[$#lines] . " day of Christmas my true love gave to me\n", join(",\n", @lines) . ".\n\n";
};

while( my $lyric = <DATA> ){
  chomp($lyric);
  $fn->($lyric);
  $fn = curry( $fn, HOLE, BLACKHOLE, $lyric );
};

__DATA__
     a partridge in a pear tree
   two turtle doves
 three french hens
  four calling birds
  five golden rings
   six geese a-laying
 seven swans a-swimming
 eight maids a-milking
  nine ladies dacing
   ten lords a-leaping
eleven pipers piping
twelve drummers drumming
