use Date::Parse;
use Date::Language; #uses Date::Format;

#Equivalent but much faster, even when casting to epoch outside the loop
#my $xmas = DateTime->now->set( month => 12, day => 25 )->epoch;
my $xmas = str2time('12/25');

for my $language (
    qw(Austrian Czech Danish Dutch English Finnish
    French German Greek Italian Norwegian Swedish)
  )
{
    my $df = Date::Language->new($language);
    print $df->time2str( "[$language] %e %B %Y\n", $xmas );
}
