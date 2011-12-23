use Text::Diff;

#See http://www.snopes.com/holidays/christmas/donner.asp
my @classic = map{"$_\n"}  #As a line-oriented algorithm you need \n for beauty
  qw/Dasher Dancer Prancer Vixen Dunder Blixem Cupid Comet/;
my @modern  = map{"$_\n"}
  qw/Rudolph Dasher Dancer Prancer Vixen Donder Blitzen Cupid Comet/;

print diff(\@classic, \@modern, {STYLE=>'OldStyle'}), "\n\n";
print diff(\@classic, \@modern, {STYLE=>'Context'}),  "\n\n";
print diff(\@classic, \@modern, {STYLE=>'Unified'}),  "\n\n";
print diff(\@classic, \@modern, {STYLE=>'Table'});
