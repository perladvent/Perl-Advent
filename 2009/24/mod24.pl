use lvalue;

{
    # Make it a closure too
    my $ary = [qw/Dasher Dancer Vixen Comet Cupid Prancer Dunder Blixem/];

    sub reindeer : lvalue {
      set {
	my $val = shift;
	die('expected reference to an array, you supplied a ', ref $val)
	  unless ref $val eq 'ARRAY';
	return $ary = $val;
      }
      get {
	return join ', ', @{$ary};
      }
    }
}

print reindeer();
print reindeer() = [qw/Dasher Dancer Vixen Comet Cupid Prancer Donner Blitzen/];
print reindeer() = {foo=>'bar'};
