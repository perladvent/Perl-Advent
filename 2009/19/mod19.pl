use Match::Smart ':all';

my %kids = ( Alice=>'nice', Bob=>'good', Eve=>'bad', Jerrad=>'???', Zack=>'naughty');

printf("%s gets a %s\n", $_, gift($kids{$_}) ) foreach keys %kids;

sub gift{
  my $behavior = shift;

  given $behavior => sub {
    when [qw/good nice/]    => sub { return "pony" };
    when [qw/bad naughty/]  => sub { return "lump of coal" };
    default sub { return "pair of socks" }; #sub is optional
  }
}
