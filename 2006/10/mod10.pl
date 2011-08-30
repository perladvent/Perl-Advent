package main;
use Fatal qw/CORE::GLOBAL::open CORE::GLOBAL::close/;

eval{ Note::thankYou(qw/Alvin Bobby Cindy David Erica Freddie/) };
warn("Naughty package! $@\n") if $@;


package Note;
use File::Temp 'tmpnam';

sub thankYou{
  foreach my $child (@_ ){
    my($fh, $file) = tmpnam();

    #Compose thank you for exceptional cookies and milk...
    
    #strict-less example using typo to force failure in closing unopened handle
    close($Fh);

    #Do something with the message $file
  }
}
