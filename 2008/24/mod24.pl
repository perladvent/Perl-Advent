use Sort::Half::Maker 'make_halfsort';

#Hooray for tuples
my @order = (Dasher=>Dancer,
	     Prancer=>Vixen,
	     Comet=>Cupid,
	     Dunder=>Blixem);

#...and a Rudy to lead!
unshift @order, 'Rudolph';


#Pseudo-random order
my @data = qw/Dunder Blixem Dasher Dancer Prancer Vixen
              Rudolph Comet Cupid Olive Chet/;

$sub = make_halfsort(start => \@order);
print join(',', sort $sub @data), "\n";
