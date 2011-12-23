package Acme::English;

use strict;
use vars qw($VERSION);

$VERSION = '1.00';

#Sesquipedalian / oglethorpe
my %chr = (
	   '<' => 'Waka',
	   '>' => 'Wakka',
	   '!' => 'Bang',
	   '*' => 'Splat',
	   "'" => 'Tick',
	   '^' => 'Carat',
	   '@' => 'At',
	   '`' => 'BackTick',
	   '#' => 'Hash', #XXX Number!
	   '$' => 'Dollar',
	   '-' => 'Dash',
	   '_' => 'Underscore',
	   '%' => 'Percent',
	   '&' => 'Ampersand',
	   ')' => 'RightParen',
	   '(' => 'LeftParen',
	   '.' => 'Dot',
	   '/' => 'Slash',
	   "\\"=> 'BackSlash',
	   '{' => 'CurLyBracket', #Right?!! Brace?!
	   '}' => 'CuRlyBracket', #Right?!! Brace?!
	   '~' => 'Tilde',
	   '|' => 'Pipe'
);
#print <DATA>;
my $in = join("\n", (<DATA>));

foreach (split('', $in) ){
    print exists($chr{$_}) ? $chr{$_} : $_, " ";
}

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__DATA__

__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

Acme::English - remove unsightly punctuation

=head1 SYNOPSIS

  use Acme::English;

=head1 DESCRIPTION

Inspired by this lovely poem:

  A poem:
  <>!*''#              waka waka bang splat tick tick hash
  ^@`$$-               carat at back-tick dollar dollar dash
  *!'$_                splat bang tick dollar underscore
  %*<>#4               percent splat waka waka number four
  &)../                ampersand right-paren dot dot slash
  {~|**SYSTEM HALTED   curly bracket tilde pipe splat splat crash

by Fred Bremmer and Steve Kroese





:pretentious Octothorpe

:jargon star hat bar twiddle

=head1 BUGS

I cheated in the default definitions of some of the characters.
Waka = < and Wakka = > (more k's, get it? ;-) CurLyBracket
(I call them CurlyBraces) is the { and CuRlyBracket is }.

=head1 AUTHOR

Jerrad Pierce <jpierce@cpan>

=head1 SEE ALSO

Acme::English, the ASCII jargon entry

=cut
