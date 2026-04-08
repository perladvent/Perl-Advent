use v5.12.0;
package Pod::Elemental::Transformer::VimHTML;

use Moose;
with 'Pod::Elemental::Transformer::SynHi';

use Encode ();
use Text::VimColor;

has '+format_name' => (default => 'vim');

sub build_html {
  my ($self, $str, $param) = @_;

  if (utf8::is_utf8($str)) {
    if ($str =~ /[\x{00C2}\x{00C3}][\x{0080}-\x{00BF}]/) {
      my $fixed = eval {
        Encode::decode(
          'utf-8',
          Encode::encode('latin-1', $str, Encode::FB_CROAK),
          Encode::FB_CROAK
        );
      };
      $str = $fixed if defined $fixed;
    }
  } else {
    $str = Encode::decode('utf-8', $str, Encode::FB_CROAK);
  }

  my $vim = Text::VimColor->new(
    string   => $str,
    filetype => $param->{filetype},
    vim_options => [
      qw( -RXZ -i NONE -u NONE -N -n ), "+set nomodeline", '+set fenc=utf-8',
    ],
  );

  my $html = $vim->html;
  $html = Encode::decode('utf-8', $html, Encode::FB_CROAK)
    unless utf8::is_utf8($html);

  return $html;
}

sub parse_synhi_param {
  my ($self, $str) = @_;

  my @opts = split /\s+/, $str;

  confess "no filetype provided for VimHTML region" unless @opts;
  confess "illegal VimHTML region parameter: $str"
    unless @opts == 1 and $opts[0] !~ /:/;

  return { filetype => $opts[0] };
}

1;
