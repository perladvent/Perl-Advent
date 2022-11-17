#Be sure to use -T and maybe CGI::Untaint if you do anything more substantial
use CGI::Minimal;
use Data::Dumper;

my($q, %);

$q = new CGI::Minimal;
$p{$_} = $q->param($_) foreach $q->param();

print "Content-type: text/plain\n\n";

$Data::Dumper::Sortkeys =1 ;
print Data::Dumper::Dumper \%p;
