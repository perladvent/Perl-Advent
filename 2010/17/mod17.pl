# How to build reindeer neighborhoods. Other applications exist as well. 
# Adam Russell ac.russell@live.com

use GD;
use Tkx;
use Math::Geometry::Voronoi;

my $main_window = Tkx::widget->new(".");
perl_advent_ui($main_window); 
&Tkx::MainLoop();

sub perl_advent_ui {
    my ($root) = @_;  
    my @points= ([272,39],
		 [130,43],
		 [87,112],
		 [294,114],
		 [166,124],
		 [247,206],
		 [93,208]);

    my @gd_polys=create_voronoi_polygons(@points);    
    my @gd_edges=create_voronoi_edges(@points);    
    my $img_filename=encode_voronoi_image(\@gd_polys,\@gd_edges, \@points);
    my $canvas = $root->new_tk__canvas(-width => 400, -height => 350);    
    my $voronoi_image=Tkx::image_create_photo(-file => $img_filename);
    my $voronoi_tag="voronoi_diagram";
    $canvas->create_image([200,200],-image => $voronoi_image, -tag=>$voronoi_tag);
    $canvas->g_grid(-column => 0, -row => 0);
}

sub create_voronoi_polygons{
    my(@points)=@_;
    my $geo = Math::Geometry::Voronoi->new(points => \@points);
    $geo->compute;    
    my @geo_polys = $geo->polygons;    
    my @gd_polys;
    foreach  my $geo_poly (@geo_polys){
        unshift @gd_polys,create_gd_poly(@{$geo_poly}[1..$#{$geo_poly}]);
    }
    return @gd_polys;
}

sub create_voronoi_edges{
    my(@points)=@_;
    my $geo = Math::Geometry::Voronoi->new(points => \@points);
    $geo->compute;    
    my @geo_edges = $geo->edges;    
    my @gd_edges;
print pp $geo->edges;     
    foreach  my $geo_edge (@geo_edges){
        unshift @gd_edges,create_gd_edge(@{$geo_edge}[0..$#{$geo_edge}],$geo->vertices,$geo->lines,$geo->points);
    }    
    return @gd_edges;
}

sub encode_voronoi_image{
    my($polys,$lines, $points)=@_;
    my $mode=">:raw";
    my $filename="voronoi.gif";
    my $img = GD::Image->new(400,400,1);
    $img->filledRectangle(0,0,500,500,0x00ffffff);
    #my $k=0;   
    #my @color_array=(255,0,0); 
    #foreach my $poly (@{$polys}) {
    #    my $color=$img->colorAllocate($color_array[0],$color_array[1],$color_array[2]);
    #    $img->openPolygon($poly,$color);
    #    if($k%2==0){
    #        $color_array[0]-=50;#every other time through the loop take the color down a notch   
    #                            #to get a small shading effect  
    #    }   
    #    ($color_array[1],$color_array[0],$color_array[2])=($color_array[0],$color_array[1],$color_array[2]);#each time through alternate red/green polys for a Christmas color scheme      
    #    $k++;  
    #}   
    my $color_black=$img->colorAllocate(0,0,0);
    foreach my $line (@{$lines}) {
        $img->line(${$line}[0],${$line}[1],${$line}[2],${$line}[3],$color_black) 
    }  
    foreach my $point (@{$points}) {
        $img->filledArc(${$point}[0],${$point}[1],3,3,0,360,$color_black);
    }  
    open  IMG, $mode, $filename  or die $!;
    print IMG $img->gif;
    close IMG;
    return $filename;
}

sub create_gd_poly{
    my(@points)=@_;
    my $pgon=new GD::Polygon;
    foreach my $point (@points){
        $pgon->addPt(@{$point});
    }
    return $pgon;
}

sub create_gd_edge{
    my $points=pop @_;
    my $lines=pop @_;
    my $vertices=pop @_;
    my(@edges)=@_;
    my @gd_endpoints;
    foreach my $edge (@edges){
        my $l_index=${$edge}[0];
        my($v_index,$x1,$y1,$x2,$y2);
        if(${$edge}[1]!=-1){  
            $v_index=${$edge}[1];
            ($x1,$y1)=(${$vertices}[$v_index][0],${$vertices}[$v_index][1]);            
        }
        if(${$edge}[2]!=-1){  
            $v_index=${$edge}[2];
            ($x2,$y2)=(${$vertices}[$v_index][0],${$vertices}[$v_index][1]);            
        }  
        my($a,$b,$c);#used for expressing the line in ax+by=c form
        $a=${$lines}[$l_index][0];
        $b=${$lines}[$l_index][1];
        $c=${$lines}[$l_index][2];
        if(${$edge}[1]==-1){          
            if($b){
                #if b is non-zero then the slope is -a/b
                my $m=-1*$a/$b;
                #calculate the y intercept
                my $y_int=$y2-($m*$x2);
                #Now set an extreme endpoint for the start of our line closer to the origin
                $x1=1;
                $y1=$m*$x1+$y_int;
            }  
        }
        if(${$edge}[2]==-1){
            if($b){
                #if b is non-zero then the slope is -a/b
                my $m=-1*$a/$b;
                #calculate the y intercept
                my $y_int=$y2-($m*$x2);
                #Now set an extreme endpoint to represent oo in our visualization
                $x2=1_000_000;
                $y2=$m*$x2+$y_int;
            }  
        }
        if(!$b){#if b is 0 then we just have a vertical line
                $x1=$c/$a; 
                $y1=rand();#any random value will do
                $x2=$c/$a;
                $y2=rand(1000);#any random value will do
        }
        unshift @gd_endpoints,[$x1,$y1,$x2,$y2];
    } 
    return @gd_endpoints;
}
