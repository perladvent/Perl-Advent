use File::SortedSeek ':all';
use Search::Dict;

my $DICT;
open($DICT='/usr/dict/words', $DICT) && do {
  my $pos;

  #Discard the returned position tell() of the closest result: Wasserman
  #Optional custom munge routine to normalize case else result is: would
  alphabetic($DICT, 'wassail', \&munge);

  #And print it; scalar context to avoid reading the whole file
  print scalar <$DICT>;

  #Try again, it automatically seeks so no need to reset
  my $pos = alphabetic($DICT, 'mistletoe', \&munge);
  
  #This time we checked if we got what we wanted, alas :all *isn't*
  printf("In %s at byte %i found exactly: %s", $DICT, $pos, scalar <$DICT>)
    if File::SortedSeek::was_exact();


  #Core distribution alternative
  $pos = look($DICT, 'mistletoe');
  printf("In %s at byte %i found exactly: %s", $DICT, $pos, scalar <$DICT>)
};


sub munge{
  local $_ = shift || return undef;
  chomp;
  return lc $_
}
