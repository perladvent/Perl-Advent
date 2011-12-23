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

# http://www.realbeer.com/holidayblog/hosers.php
__DATA__
     a beer
   two turtlenecks
 three french toast
  four pounds of back-bacon
  five golden toques!
   six packs of Tuborg
 seven packs of smokes
 eight comics books
  nine mystery day #1
   ten mystery day #2
eleven mystery day #3
twelve donut holes
