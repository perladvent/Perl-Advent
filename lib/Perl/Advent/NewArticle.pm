package Perl::Advent::NewArticle;

use v5.10;
use strict;
use warnings;

use Exporter qw(import);

our @EXPORT_OK = qw(
    discover_years
    default_year
    slugify_title
);

sub discover_years {
    my ($base_dir) = @_;
    $base_dir //= '.';

    opendir my $dh, $base_dir or die "Could not open <$base_dir>: $!";
    my @years;
    while ( my $entry = readdir $dh ) {
        next unless $entry =~ /\A\d{4}\z/;
        next unless -d "$base_dir/$entry";
        next unless -f "$base_dir/$entry/advent.ini";
        push @years, 0 + $entry;
    }
    closedir $dh;

    return sort { $a <=> $b } @years;
}

sub default_year {
    my ( $base_dir, $current_year ) = @_;
    $base_dir     //= '.';
    $current_year //= (localtime)[5] + 1900;

    my @years = discover_years($base_dir);
    return $current_year if grep { $_ == $current_year } @years;
    return $years[-1] if @years;

    return $current_year;
}

sub slugify_title {
    my ($title) = @_;
    ( my $slug = lc($title) ) =~ s/\W+/-/g;
    $slug =~ s/\A-+|-+\z//g;
    return $slug;
}

1;
