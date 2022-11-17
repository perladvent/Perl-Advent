# A fun little Christmas themed Tkx app.
# Adam Russell ac.russell@live.com
use Tkx;

my $main_window = Tkx::widget->new(".");
perl_advent_ui($main_window); 
&Tkx::MainLoop();

#Layout the ui. This sort of thing is generally easier in a RAD tool
#like specTcl or ZooZ but our layout is straightforward enough
sub perl_advent_ui {
    my ($root) = @_;  
    my $extra_nice_selected=0;
    my $do_blink=0;
    my $canvas = $root->new_tk__canvas(-width => 340, -height => 350);
    
    # All images from www.openclipart.org
    #     christmas tree: www.openclipart.org/detail/15032
    #     presents      : www.openclipart.org/detail/98539
    #     cat           : www.openclipart.org/detail/33241
    my $presents_image=Tkx::image_create_photo(-file => "xmas-presents_0.gif");
    my $presents_tag="presents";
    my $kitten_image=Tkx::image_create_photo("kitten", -file => "kitten_0.gif");
    my $kitten_tag="kitten";
    my $tree_image=Tkx::image_create_photo(-file => "tree_0.gif"); 
    my $tree_tag="tree";
    $canvas->create_image([172,175],-image => $tree_image, -tag=>$tree_tag);
    my @lights=string_lights(\$canvas);
   
    my $checkbox_blink=$root->new_ttk__checkbutton(-text => "Blink Lights", 
	                 -variable => \$do_blink, -onvalue => 1, -offvalue => 0);
    my $checkbox_xnice = $root->new_ttk__checkbutton(-text => "Extra Nice   ", -command => sub{extra_nice(\$canvas,\$extra_nice_selected,\$kitten_image,$kitten_tag)},
	                 -variable => \$extra_nice_selected, -onvalue => 1, -offvalue => 0);
    my $button_lights = $root->new_ttk__button(-text => "Turn on the lights", -command => sub {turn_on_lights(\$canvas,\$checkbox_blink,\$do_blink,@lights);});
    my $button_nolights = $root->new_ttk__button(-text => "Turn off the lights", -command => sub {turn_off_lights(\$canvas,\$checkbox_blink,\$do_blink,@lights);});
    my $button_naughty = $root->new_ttk__button(-text => "Naughty", -command => sub{naughty(\$canvas,\$checkbox_xnice,\$extra_nice_selected,$presents_tag,$kitten_tag);});
    my $button_nice = $root->new_ttk__button(-text => "Nice", -command => sub{nice(\$canvas,\$checkbox_xnice,\$presents_image,$presents_tag);});  

    my $row_start = 1;
    $canvas->g_grid(-column => 0, -row => 0, -columnspan => 7, -rowspan => $row_start);
    
    $button_naughty->g_grid(-column => 0, -row => $row_start+1, -columnspan => 1);
    $button_nice->g_grid(-column => 1, -row => $row_start+1, -columnspan => 1);
    $checkbox_xnice->g_grid(-column => 2, -row => $row_start+1, -columnspan => 1);
    $checkbox_xnice->state("disabled");
    
    $button_lights->g_grid(-column => 0, -row => $row_start+3, -columnspan => 1);
    $button_nolights->g_grid(-column => 1, -row => $row_start+3, -columnspan => 1);
    $checkbox_blink->g_grid(-column => 2, -row => $row_start+3, -columnspan => 1); 
    $checkbox_blink->state("disabled");
    turn_off_lights(\$canvas,\$checkbox_blink,\$do_blink,@lights);
    blink_lights(\$canvas,\$do_blink,@lights);
}

sub string_lights{
    my($canvas)=@_;
    my @light_ids;
    my ($x_top_left,$y_top_left,$x_bottom_right,$y_bottom_right)=(142.00,68.00,146.00,74.00);
    foreach my $row_index (0..10){
        foreach my $light_index (0..10+($row_index-5)){
            my $scatter=rand(7);
            $light_index=$light_index*10;
            my $light=$$canvas->create_oval($x_top_left+$light_index,$y_top_left+$scatter,$x_bottom_right+$light_index,$y_bottom_right+$scatter, -fill => "yellow", -tags => "palette palettered");
            unshift @light_ids, $light;
        }
        ($x_top_left,$y_top_left,$x_bottom_right,$y_bottom_right)=($x_top_left-5,$y_top_left+15,$x_bottom_right-5,$y_bottom_right+15)
    }
    return @light_ids;
}

sub turn_on_lights(){
    my($canvas,$checkbox,$checkbox_selected,@lights)=@_;
    foreach my $light_id (@lights){
        $$canvas->itemconfigure($light_id, -state => "normal");
    }
    $$checkbox->state("!disabled");
    $$checkbox_selected=0;
}

sub turn_off_lights(){
    my($canvas,$checkbox,$checkbox_selected,@lights)=@_;
    foreach my $light_id (@lights){        
        $$canvas->itemconfigure($light_id, -state => "hidden");
    }
    $$checkbox->state("disabled");
    $$checkbox_selected=0;
}

sub blink_lights{
    my($canvas,$do_blink,@lights)=@_;
    repeat(1000,sub{blink_switch($canvas,$do_blink,@lights)});
}

sub blink_switch{
    my($canvas,$do_blink,@lights)=@_;
    my @lights_off;
    my $random_off_switch;
    if($$do_blink){
        foreach my $light_id (@lights){ 
            $random_off_switch=(rand()<.5);
            if($random_off_switch){
                $$canvas->itemconfigure($light_id, -state => "hidden");
                unshift @lights_off, $light_id;
            }
        }
        Tkx::update();
        Tkx::after(500);
        foreach my $off_light_id (@lights_off){
            $$canvas->itemconfigure($off_light_id, -state => "normal"); 
        }
        Tkx::update();
    }
}

sub naughty{
    my($canvas,$checkbox,$checkbox_selected,$presents_tag,$kitten_tag)=@_;
    $$canvas->delete($presents_tag);
    $$canvas->delete($kitten_tag);
    $$checkbox->state("disabled");
    $$checkbox_selected=0;
}

sub nice{
    my($canvas,$checkbox,$presents,$tag)=@_;  
    $$canvas->create_image([65,325],-image => $$presents, -tag=>$tag);
    $$checkbox->state("!disabled");
}

sub extra_nice{
    my($canvas,$extra_nice_selected,$kitten,$tag)=@_;  
    if($$extra_nice_selected){
        $$canvas->create_image([297,310],-image => $$kitten, -tag=>$tag);
    }
    else{
        $$canvas->delete($tag);
    }
}

# Implementation of a function like Perl/Tk's repeat
# from http://www.nntp.perl.org/group/perl.tcltk/2010/02/msg381.html
# for additional discussion see http://www.perlmonks.org/index.pl?node_id=728516
sub repeat{
    my $ms  = shift;
    my $sub = shift;
    my $repeater; # repeat wrapper
    $repeater = sub { $sub->(@_); Tkx::after($ms, $repeater);};
    my $repeat_id=Tkx::after($ms, $repeater);
    return $repeat_id;
}
