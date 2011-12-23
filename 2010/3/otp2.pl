use Win32 ();
use Win32::GUI;
use Win32::GUI::Loft::Design;

my $binfmt = "otp2.gld";
my $layout = Win32::GUI::Loft::Design->newLoad($binfmt) or
  die("Could not open window file ($binfmt)");

$win = $layout->buildWindow() or die("Could not build window\n");
$win->Center(); $win->Show(); #Window position is saved in layout...
$win->SetForegroundWindow();
$win->param->SetFocus();
Win32::GUI::Dialog();         #Event loop


use vars qw($win @param);
use Crypt::SKey;

sub ::param_MouseMiddleDown{
  $win->param->Paste();
  $win->pass->SetFocus();
}

sub ::param_LostFocus{
  my $param = $win->param->Text();
  $param =~ s/^\s+//;
  @param = split/[- ]+/, $param;
  $Crypt::SKey::HASH = uc($param[1]);
}

#Trapping 'VK_ENTER' is a bear so recalculate as we go, plus it looks cool
sub ::pass_Change{
  $win->skey->Text( Crypt::SKey::compute(@param[2,3], $win->pass->Text()) );
  $win->skey->Select(0,-1); $win->skey->Copy();
}
__DATA__
#Despite documentation, filename parameter to newScalar is not optional
#my $code = decode_base64(do{ local $/; <DATA> });
#my $layout = Win32::GUI::Loft::Design->newScalar($code, '__DATA__') or
#  die("Could not build window file <DATA>\n");
