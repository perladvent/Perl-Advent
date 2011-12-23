use File::Which;

for my $perl ( where('perl') ) {
    my $output = `$perl -v`;
    if ( $output =~ /v(\d+\.\d+\.\d+)/ ) {
        my $version = $1;
        if ( $version =~ /5\.10/ ) {
            print "Santa brought us Perl $version and left it at $perl\n";
        }
        else {
            print "Crummy old Perl $version is still at $perl\n";
        }
    }
}
