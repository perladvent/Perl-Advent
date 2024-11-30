#!/usr/bin/env perl

use v5.26;

use DateTime   ();
use Path::Tiny qw( path );

my $year = DateTime->now->year;

path("$year/articles")->mkpath;
path("$year/share/static")->mkpath;

my $counter = 1;

my $i = 0;
for my $file ( path( $year, 'incoming' )->children(qr/\.pod$/) ) {
    ++$i;
    my $day  = DateTime->new( year => $year, month => 12, day => $i );
    my $dest = path( $year, 'articles', $day->ymd . '.pod' );
    say $file->basename. ' being moved to ' . $dest;
    $file->copy($dest);
}

for my $file ( path( $year, 'incoming' )->children(qr/.*/) ) {
    next if $file =~ qr{pod\z};
    my $dest = path($year, 'share', 'static', $file->basename );
    say "🚚 copy $file to $dest";
    $file->copy( $dest  );
}

my $cmd = "./script/build-site.sh --single-year $year --today $year-12-25";
say "🚀 running $cmd";
my $result = `$cmd`;
say $result;

say
    qq{You can now view the calendar by running: "http_this --autoindex out/$year"};
