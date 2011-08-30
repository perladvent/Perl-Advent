#!/usr/bin/perl
use CGI::Ajax;
use CGI::Minimal;

my $query = new CGI::Minimal;
my $AJAX = new CGI::Ajax( jsMethod=> \&perlMethod);

print $AJAX->build_html($query, \&createContent);

sub perlMethod{
  $_ = shift;
  s/for/4/;
  s/tw?oo?/2/;
  $_ .= ' lol' if rand() > .9;
  return uc;
}

sub createContent{
  undef $/;
  return <DATA>;
}
__DATA__
<html><head>
<body>
This is our simple web page, you could use your favorite templating system
as well, anything that returns a string of HTML.
<p>
<form>
<input id="IN1" type="text" size="12" onKeyUp="jsMethod(['IN1'], ['OUT1'] );">
</form>
<div id="OUT1" style="color:white; background-color:black">
AJAX results show up here, input is AOL echoed.
</div>
</body></html>
