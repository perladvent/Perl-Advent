#!/usr/bin/env perl

use v5.26;

use DateTime   ();
use Path::Tiny qw( path );
use JSON::PP   qw( encode_json );

my $now  = DateTime->now;
my $year = $now->year;

path("$year/articles")->mkpath;
path("$year/share/static")->mkpath;

# Track mappings from incoming files to their assigned dates
my @mappings;

# If it's December, try not to clobber existing articles.
my $i = $now->month == 12 ? DateTime->now->day + 1 : 1;
for my $file ( path( $year, 'incoming' )->children(qr/\.pod$/) ) {
    ++$i;
    my $day  = DateTime->new( year => $year, month => 12, day => $i );
    my $dest = path( $year, 'articles', $day->ymd . '.pod' );
    while ( $dest->exists ) {
        ++$i;
        $dest = path( $year, 'articles', $day->ymd . '.pod' );
    }
    say $file->basename . ' being moved to ' . $dest;
    $file->copy($dest);

    # Record the mapping
    push @mappings, {
        incoming => $file->stringify,
        article  => $dest->stringify,
        html     => $day->ymd . '.html',
    };
}

for my $file ( path( $year, 'incoming' )->children(qr/.*/) ) {
    next if $file =~ qr{pod\z};
    my $dest = path( $year, 'share', 'static', $file->basename );
    say "🚚 copy $file to $dest";
    $file->copy($dest);
}

my $cmd = "./script/build-site.sh --single-year $year --today $year-12-25";
say "🚀 running $cmd";
my $result = `$cmd`;
say $result;

# Write the mapping file for screenshot workflow
if (@mappings) {
    my $mapping_file = path('incoming-mappings.json');
    $mapping_file->spew(encode_json(\@mappings));
    say "📋 Wrote article mappings to $mapping_file";
}

say
    qq{You can now view the calendar by running: "http_this --autoindex out/$year"};
