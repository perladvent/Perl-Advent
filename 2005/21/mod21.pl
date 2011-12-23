use Want;
use Lingua::EN::Numbers::Ordinate;

my @days = <DATA>;

sub days :lvalue {
  if( want('LVALUE', 'ASSIGN') ){
    my $n = shift;
    $days[$n] = want('ASSIGN');
    lnoreturn;
  }
  if( want('SCALAR') ){
    my $str = '';
    foreach( 1..12 ){
      $str .= sprintf $days[0], ordinate($_);
      $str .= join '', reverse(@days[1..$_]), "\n";
    }
    rreturn $str;
  }
  if( want('LIST') ){
    my $n = shift || want('COUNT');
    if( $n ){
      rreturn @days[1..$n];
    }
    else{
      rreturn @days;
    }
  }
  return;
}

#Rewrite the lyrics
days(5) = "Five onion rings!\n";

#Stringified
print scalar days;

#Equivalent subsets
my @gifts = days(3);
my($gift1, $gift2, $gift3) = gifts;
(days)[1..3];

__DATA__
On the %s day of Christmas, my true love gave to me
A partridge in a pear tree.
Two turtle doves
Three French hens
Four calling birds
Five golden rings.
Six geese a-laying,
Seven swans a-swimming
Eight maids a-milking
Nine ladies dancing
Ten lords a-leaping
Eleven pipers piping
Twelve drummers drumming
