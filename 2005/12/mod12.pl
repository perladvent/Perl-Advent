use re 'debugcolor';

my %abbrev = (
	      hippopotamus=>'hippo',
	      Christ=>'X-'
	     );

print $_ = "I want a hippopotamus for Christmas\n";

my $EXPR = join('|', keys %abbrev);

s/($EXPR)/$abbrev{$1}/g;

print;
