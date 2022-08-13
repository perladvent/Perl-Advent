use strict;
use warnings;
use open qw/ :std :utf8 /;
use Mojo::UserAgent;
use Text::CSV qw( csv );

my %suffixes = (
    1  => 'st',
    2  => 'nd',
    3  => 'rd',
    21 => 'st',
    22 => 'nd',
    23 => 'rd'
);

# Get all tutorials that are already listed
my $tutorials = csv(
    in      => "../learncpan/tutorials.csv",
    headers => "auto"
);

my %dists;
foreach my $tutorial (@$tutorials) {
    $dists{ lc $tutorial->{distribution} } = 1;
}

my $ua = Mojo::UserAgent->new;

my @rows;
my @days = ( 1 .. 25 );

foreach my $year ( 2002 .. 2004 ) {
    foreach my $day (@days) {

        my $url = get_url( $year, $day );
        get_articles( $url,
            { title_selector => 'title', module_selector => 'div.modtitle' } );
    }
}


# There is no sure way of identyfing the main module in the article for these years from the HTML
foreach my $year ( 2005 .. 2010 ) {
    foreach my $day (@days) {

        my $url = get_url( $year, $day );
        my $dom = get_dom($url);
        next unless $dom;
        my $title = $dom->at('title');

        push @rows, [ 'TODO', $url, $title ];
    }
}

foreach my $year ( 2011 .. 2019 ) {
    foreach my $day (@days) {

        my $url = get_url( $year, $day );
        get_articles( $url,
            { title_selector => 'h1.title', module_selector => 'div.subtitle' }
        );
    }
}

my @all    = csv( in => "../learncpan/tutorials.csv" );
my @merged = ( @{ $all[0] }, @rows );
my $csv = Text::CSV->new( { binary => 1, auto_diag => 1, quote_char => undef } );
open my $fh, ">:encoding(utf8)", "../learncpan/tutorials.csv"
  or die "tutorials.csv: $!";
$csv->say( $fh, $_ ) for @merged;
close $fh or die "tutorials.csv: $!";

sub get_articles {
    my ( $url, $args ) = @_;

    my $dom = get_dom($url);
    return unless $dom;
    my $ts     = $dom->at( $args->{title_selector} );
    my $ms     = $dom->at( $args->{module_selector} );
    my $title  = $ts->text if $ts;
    my $module = $ms->text if $ms;

    unless ($module) {
        print "Module not found at $url \n";
        return;
    }

    $title  =~ s/,//g;
    $module =~ s/\s-\s.+//;
    $module =~ s/::/-/g;

    # If $module stil has a white space at this point it may contain more than one module.
    if ( $module =~ m/\s/ ) {
        my (@mods) = $module =~ m{\w+\-\w+(?:\-\w+)?}g;
        if (@mods) {
            foreach my $mod (@mods) {
                unless ( $dists{ lc $mod } ) {
                    $dists{$mod} = 1;
                    push @rows, [ $mod, $url, $title ];
                }
            }
            return;
        }
        else {
            print "Not a module: $module at $url \n";
            return;
        }
    }

    unless ( $dists{ lc $module } ) {
        $dists{$module} = 1;
        push @rows, [ $module, $url, $title ];
    }
}

sub get_url {
    my ( $year, $day ) = @_;

    my $url;
    if ( $year >= 2011 ) {
        $url = sprintf 'https://perladvent.org/%s/%s-12-%02d.html', $year,
          $year, $day;
    }
    elsif ($year == 2000
        || ( $year >= 2005 && $year <= 2008 )
        || $year == 2009
        || $year == 2010 )
    {
        $url = sprintf 'https://perladvent.org/%s/%s/', $year, $day;
    }
    elsif ( $year > 2000 && $year <= 2004 ) {
        my $suffix = $suffixes{$day} ? $suffixes{$day} : 'th';
        $url = sprintf 'https://perladvent.org/%s/%s%s/', $year, $day, $suffix;
    }

    return $url;
}

sub get_dom {
    my $url = shift;

    my $res = $ua->get($url)->result;
    unless ( $res->is_success ) {
        print "Couldn't process $url \n";
    }

    return $res->dom;
}
