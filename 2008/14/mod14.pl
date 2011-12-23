#!/usr/bin/perl 

use strict;
use warnings;

use Text::SpellChecker;
use Lingua::Ident;
use Lingua::Translate;

Lingua::Translate::config( back_end => 'Google' );

my $letter = join '', <>;

print "--- original letter:\n\n$letter\n\n";

# TODO: add all the languages of the world. -- Glugg
my $ident = Lingua::Ident->new( map "data.$_" => qw/ en fr de / );

my $speller = Text::SpellChecker->new(
    text => $letter,
    lang => $ident->identity($letter),
);

while ( my $word = $speller->next_word ) {

    # just take the first suggestion,
    # if there is one
    my ($corrected) = $speller->suggestions;
    $speller->replace_all( new_word => $corrected ) if $corrected;
}

print "--- corrected letter:\n\n", $speller->text, "\n\n";

my $xl8r = Lingua::Translate->new( src => $lang, dest => 'en' );

print "--- translated letter:\n", $xl8r->translate( $speller->text ), "\n\n";

__END__
