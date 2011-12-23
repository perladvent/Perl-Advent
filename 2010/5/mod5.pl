use Clutter '-init';
use Champlain;

# Create the canvas
my $stage = Clutter::Stage->get_default();
$stage->add(my $map = Champlain::View->new);
$_->set_size(800, 600) foreach $map, $stage;
$map->set_scroll_mode(CHAMPLAIN_SCROLL_MODE_KINETIC); #w/ inertia
$map->set_show_scale(1);

# Pin the tail on the donkey
$map->set_zoom_level(11);
$map->center_on(42.33, -71);

# Reveal the results
$stage->show_all();
Clutter->main();
