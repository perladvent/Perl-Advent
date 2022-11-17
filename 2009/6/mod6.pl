use XML::Twig;
use 5.010;

my $t = XML::Twig->new(
    pretty_print => 'indented',  # output  nicely formatted
    keep_spaces => 1,             # wrap as original layout
    empty_tags   => 'html',        # outputs <empty_tag />
);

$contents = do { local $/; <> };    # slurp scarf

# repair html to wellformed xml
$contents =~ s[< $_ (?: \b [^>]*? [^/])? \K >][ />]gxism for qw[ link br img];
$contents =~ s[&middot;][&#183;]gxism;

eval { $t->parse($contents) }
   or die "$@ \n contents = $contents\n";
   ;
my $root = $t->root;
my @para =
  $root->get_xpath('.//a[@href=""]');    # get the  children [@class="q"]/a
foreach my $para (@para) {
    $para->set_text( $para->text() + 1 );
    $para->delete() if $para->text() > 25;
}

# output the document
$contents = $t->sprint($root);           
$contents =~ s[\xb7][&middot;]gxism;     # restore html entities
print $contents;

