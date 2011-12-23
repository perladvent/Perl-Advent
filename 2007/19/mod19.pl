#! perl
use feature ':5.10'; # or ...
# use 5.10.0; or 5.9.5 or v5.10 or 5.010

sub hello;
while (@ARGV){
 given(shift){
   when("hello"){hello; }
   when("hello world"){hello; }
   when('Hello World'){hello; }
   when(q{world}){hello;   }
   when(/ \b hello [-\s\W_]?+(?<Name>\w+)/ix){
	hello $+{Name}; }
   when(/ \A (?: false | 0{1}+ [.0]* | \s++ | ) \Z /ix){
	hello 0; } # false but defined
   when(/ null | undef /ix){hello undef } #  undef
   when(/\b hello \b/ix){hello; } #catch others
   when(/(?<J>j)(?<A>a)(?<P>p)(?<H>h)/ix){
	hello("$+{J}ust $+{A}nother $+{P}erl 5.10 $+{H}acker");
	}
   default { say "what '$_'?";    }
 }
}

sub hello {
  my ($msg)=@_;
  state $n=0;
  $msg //= 'World';      
  say "Hello $msg",
        $n++ ? " for the ${n}th time" : "";
}
