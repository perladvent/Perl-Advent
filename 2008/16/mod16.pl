#! perl -ls
### Purpose - Find Words that are time_t's or vice versa
use vars qw{$x $geometry};
use SelfLoader;

## just do it
if( $x ){
  eval "use Tk";
  $geometry ||= '+0+0';
  GUI();
}
else{
  my $fmt = "%stime_t: %i\n   oct: %s\n   hex: %s\n ascii: %s\n local: %s\n  zulu: %s\n";

  if (@ARGV) {
    ## simulate
    printf $fmt, '', it( bytes_to_nums(shift) ) while @ARGV;
  }
  else{
    my $cls = CLI();
    printf $fmt, $cls, it( time() ) while ( sleep(1) )
  }
}


sub bytes_to_nums {
  my $string = shift;
  ## Probably has problems if given more than 4 chars?
  my $long = unpack( "N*", pack( "a*", $string ) );
  return $long;
}

sub nums_to_bytes {
  my $long = shift;
  ## Probably has problems if given more than 4 chars?
  my $string = unpack( "a*", pack( "N*", $long ) );
  return $string;
}

sub it {
  my @Bufs;
  my $t = shift;
  
  push @Bufs, scalar($t);
  push @Bufs, scalar( sprintf "%o", $t );
  push @Bufs, scalar( sprintf "%X", $t );    # require 5.010; my $_ =
  push @Bufs,
    scalar
      do { local $_ = nums_to_bytes($t); s/[^[:print:]]/chr 0x3F/ge; "'$_'"; };
  push @Bufs, scalar localtime($t);
  push @Bufs, scalar gmtime($t);
  
  return wantarray ? @Bufs : \@Bufs;
}


__DATA__
sub CLI{
  my $cls;
  # from FAQ http://perldoc.perl.org/perlfaq8.html#How-do-I-clear-the-screen%3F
  if ( $^O =~ /MSWin/ ) {
    $cls = "";
  }
  else {
    use Term::Cap;
    my $terminal = Term::Cap->Tgetent( { OSPEED => 9600 } );
    my $clear_string = $terminal->Tputs('cl');
    $cls = $clear_string;
  }
  return $cls;
}

sub GUI{
  use Tk;
  # based on Tk/demos/timer
  
  my $MW = MainWindow->new;

  $MW->overrideredirect(1);
  $MW->geometry($geometry);

  $MW->bind( '<Control-c>' => \&exit );
  $MW->bind( '<Control-q>' => \&exit );
  
  # %tinfo:  the Timer Information hash.
  # Key       Contents
  # w         Reference to MainWindow.
  # p         1 IIF paused.
  # t0..t9         Value of -textvariables
  my (%tinfo) = ( 'w' => $MW, 'p' => 0, );
  
  my $lines = scalar @{ [ it( time() ) ] };
  my @lines = map {
    $MW->Label(
	       -relief       => 'raised',
	       -width        => 25,
	       -textvariable => \$tinfo{ 't' . $_ },
	       -foreground => 'green',
	       -background=>'black',
	      );
  } 0 .. ( $lines - 1 );
  $_->pack() for @lines;
  

  sub tick {
    # Update the counter every 50 milliseconds, or 5 hundredths of a second.
    
    return if $tinfo{'p'};
    my @ry = scalar(@ARGV) ? bytes_to_nums($ARGV[0]) : time;
    @tinfo{ 't0' .. "t$lines" } = it( @ry );
    $tinfo{'w'}->after( 50, \&tick );
  }

  $tinfo{'w'}->after( 100, \&tick );
  MainLoop;
  
  exit;
}

__END__

=pod

=head1 NAME

time_t2X - display time_t in a variety of formats

=head1 SYNOPSIS

time_t2X [B<-x>] [B<-geometry>=I<geometry>] [I<word>]

=head1 DESCRIPTION

Display a live clock, or the time(s) corresponding to 4-character string(s)
provided on the command line.

=head1 OPTIONS

=over

=item -x

Graphical display

=item -geometry

Geometry of graphical display

=back

=head1 AUTHORS

Bill 'N1VUX' Ricker, with alterations by Jerrad Pierce

=end
