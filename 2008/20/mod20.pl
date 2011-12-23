use Tie::OneOff;
use Text::Metaphone;
use String::Approx 'amatch';

tie my %ahash, 'Tie::OneOff', do{
  my %_hash, #Private stash w/o a closure
    {
     BASE  => \%_hash,
     FETCH => sub {
       my $key = shift;
       return undef unless %_hash;
       return $_hash{$key} if exists $_hash{$key};
       my %real = map{ Metaphone($_)=>$_ } keys %_hash;
       my @like = amatch(Metaphone($key), ['15%'], keys %real);
       return @like ? $_hash{ $real{$like[0]} } : undef;
     },
     STORE => sub { $_hash{$_[0]} = $_[1] }
    }
  };

@ahash{'Jerrad Pierce', 'John Jacob Jingleheimer Schmidt'} =
      ('Snowpeak titanium sporks', 'Speak & Spell');

print join("\n", @ahash{'Jarad Pearse', 'Jon Jacob Jinglehiemer Schmitt'}, '');
#Snowpeak titanium sporks
#Speak & Spell
