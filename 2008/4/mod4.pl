use Lingua::Ident;

#Load sample tables from module
$i = new Lingua::Ident(qw(data.en data.fr));

#What's what?
printf("$_ => %s\n", $i->identify($_)) while( chomp($_=<DATA>) );

__DATA__
Hyper Blocs ColorÃÂ©s
Mega Color Blox
Elmo
Monsieur Patate
