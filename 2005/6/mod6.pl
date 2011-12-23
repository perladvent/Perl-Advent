use Interpolation ucwords=>ucwords, "'"=>sqlescape, round=>round, eval=>'eval',
  title=>\&titleCase;
use constant PI => 4 * atan2(1, 1);

#Let's checkout round and eval
{
  #Note the syntax when calling round to force PI to be seen as an expression
  print "Urban Legend: AL tried to define Pi as $round{+PI}\n",
    "To this day a unit circle in Hunstsville has an area of $eval{1**2*PI}\n";
  
  #=Urban Legend: AL tried to define Pi as 3
  #=To this day a unit circle in Hunstsville has an area of 3.14159265358979
}

#ucwords
{
  #You can even use it without Interpolation
  #Is this starting to sound a little like a former featured module?
  print $ucwords{'an easy interface akin to the hard to remember sequences: \u\L and \l\U'}, "\n";

  #=An Easy Interface Akin To The Hard To Remember Sequences: \U\L And \L\U
  #...and it works on every word too
}

#sqlescape
{
  #Can't be bothered with placeholders?
  my $lastname = q(O'Reilly); sub Select;

  Select "firstname From ACCOUNTS Where lastname=$'{$lastname}'";
  #=Selecting... q<firstname From ACCOUNTS Where lastname='O''Reilly'>
}

#custom titleCase
{
  sub titleCase{
    my @F = split /\b/, $_[0];

    #This is the kind of nonsense this module is intended to avoid
    join '', "\u\L@{[shift @F]}",
      map { /^(?:a|the|in|at|on|near|over|an)$/i ? lc $_ : "\u\L$_" } @F;
  }
  print $title{'HORTON hears A who'}, "\n";
  #=Horton Hears a Who
  print $title{'The bridge on the River Kwai'}, "\n";
  #=The Bridge on the River Kwai
}


#Pay no attention to the man behind the curtain
sub Select{
  print "Selecting... q<$_[0]>\n";
}
