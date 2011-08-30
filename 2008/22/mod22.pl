use Regexp::Subst::Parallel;

$_ = "I like apples but I don't like oranges.\n";

#Off-the-cuff implementation: I like bananas but I don't like pinebananas.
{
  local $_=$_;
  s/orange/pineapple/g;
  s/apple/banana/g;
  print;
}

#Carefully crafted regexp:    I like bananas but I don't like pineapples.
{
  local $_=$_;
  s/orange/pineapple/g;
  s/\bapple/banana/g;
  print;
}

#Considered ordering:         I like bananas but I don't like pineapples.
{
  local $_=$_;
  s/apple/banana/g;
  s/orange/pineapple/g;
  print;
}

#Care-free substitution:      I like bananas but I don't like pineapples.
{
  local $_=$_;
  print subst($_,
	      'orange'=>'pineapple',
	      'apple' =>'banana');
}
