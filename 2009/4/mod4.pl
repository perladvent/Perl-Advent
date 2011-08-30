use constant {
    N    => 100,     # number passees between progress dots
    COLS => 80,      # how many wide on progress
    HOUR => 3600,    # magic number, seconds per hour
};
use Every;

while (1) {
    1;               # .... load files in input stream here ...
}
continue {

    # Progress
    print(
        (
            every(5)
            ? ( every(2) ? q(x) : q(v) ) # 5*2=10 
            : '.'
        ),
        ( every(COLS) ? "\n" : q() )
    ) if every(N);

    backup_incremental()
      and print( "\nbackup \@ ", scalar localtime, "\n" )
      if every( seconds => HOUR ) ;
}

exit;
sub backup_incremental { 1 }
