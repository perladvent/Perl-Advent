use Acme::POE::Knee;

$stable = new Acme::POE::Knee(
			      dist        => 7,         # Days until Xmas eve
			      ponies  => {
					  Dasher=>1.4,  # Weights are my
					  Prancer=>1.2, # Guesstimation of
					  Vixen=>1.7,   # "popularity"**-1
					  Comet=>1.5,   # or forgetability
					  Cupid=>1.6,
					  Donner=>1.1,
					  Blitzen=>1.3,
					  Rudolph=>1.0,
					  Olive=>2
					 },
			     );
$stable->race;
