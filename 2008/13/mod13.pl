#!/usr/bin/perl 

use strict;
use warnings;

use Text::SpellChecker;
use Lingua::Ident;

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
    #Bonus feature
    $speller->replace_all( new_word => $corrected ) if $corrected;
}

print "--- corrected letter:\n\n", $speller->text, "\n\n";

__END__
