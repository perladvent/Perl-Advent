#!perl -w
use strict;
use warnings;

# Xmas tree PNG on stdout
use GD::Simple;

# create a new image
my ($imgWide, $imgTall) = (480, 480);
my $img = GD::Simple->new($imgWide, $imgTall);

# my Custom metallics
use Graphics::ColorNames qw(hex2tuple);
tie our %colors, 'Graphics::ColorNames', 'Metallic';
my $gold   = $img->colorAllocate(hex2tuple $colors{gold3});
my $silver = $img->colorAllocate(hex2tuple $colors{silver});

# Draw Border and background
$img->bgcolor('lightblue');
my $border = 50;
$img->fgcolor($gold);
$img->penSize($border, $border);
$img->rectangle($border/2, $border/2, $imgWide-$border/2, $imgTall-$border/2);


# Tree is a triangle based at @Center
my @Center=(240, 400);
warn "Center @ @Center";
# but Draw trunk first, so it's under foliage
$img->fgcolor(undef);
$img->bgcolor('brown');
$img->rectangle(
		add2(@Center,(-20, -30)), 
		add2(@Center,(+20, +30)),
	       );
# Foliage
my ($wt, $ht)=(150, 300);                     # $wt = half width
my @Top;
my $poly = new GD::Polygon;
$poly->addPt(     add2(@Center,(-$wt,   0)));
$poly->addPt(     add2(@Center,(+$wt,   0)));
$poly->addPt(@Top=add2(@Center,(   0,-$ht))); # y goes Down page :-(
$img->bgcolor('green');                       # trees are green
$img->fgcolor('green');
$img->penSize(1, 1);
$img->polygon($poly);                         # draw tree

my @Balls=(
	   'mediumblue', 'purple', 'crimson', 'darkorange',
	   $img->colorAllocate(hex2tuple $colors{gold1}),
	  );

# Always hang tinsel *last* on a real tree, 
# but to make it fall "behind" balls, we draw it first.
HangTinsel(  add2(@Center, randPoint($wt, -$ht))) for (1..900);

# Hang a ball on the highest bough
HangBall( 4, @Top);
# Random balls
HangBall($_, add2(@Center, randPoint($wt, -$ht)))
  for( 1 .. (9 * scalar @balls) );

# convert into png data
print $img->png;

#=============================
# subs
#=============================

#center a ball on X, Y
sub HangBall{                                 # number, X, Y
        my $n=shift;                          # leave point in @_
        my $m = scalar(@Balls);
        my ($c1,$c2)=(
		      $n % $m,                # sequential through colors
		      rand($m),               # random border/shine
		     );
        $img->bgcolor($Balls[$c1]);
        $img->fgcolor($Balls[$c2]);
        $img->penSize(1, 1);
        $img->moveTo(@_);
        $img->ellipse(15, 15);                # circle is ellipse where a=b=r
}

#tinsel hangs from: X, Y
sub HangTinsel{
        $img->fgcolor($silver);
        $img->bgcolor(undef);
        $img->penSize(2, 2);
        $img->angle(90);
        $img->moveTo(@_);
        $img->line(10);
}


# add points: (X,Y),(a,b)-> (X+a, Y+b). 
# Points can be passed as arrays, lists, or coordinates; Perl flattens free
sub add2 {
        warn "Useless use of add2() for points in scalar context" unless wantarray; 
        my ($x1, $y1, $x2, $y2)=@_;
        my $sum=[($x1+$x2), ($y1+$y2)];
        return @{$sum};
}

#rnadom point within bounds: half-width, height
sub randPoint{
        # Pick a point in a rectangle
        # with two random reals 0..1
        # but transform into 
        # triangle, as they have the same
        # area -
        #    /\     ^   | |
        #   /__\    h   |_|
        #    ww  = 2*w   w 
        # before or after usual scaling 1*1 to w*h 

        my ($wt, $ht)=@_;
        my ($x, $y)=(rand(), rand());
        if( ($x+$y) > 1 ){ 
                # fold upper right half rectangle
                # to   lower right half triangle
                $x = -1*(1 - $x);
                $y = 1 - $y; 
        }
        return @{[ $wt*$x, $ht*$y ]};
}
