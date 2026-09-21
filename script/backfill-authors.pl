#!/usr/bin/env perl
use v5.26;
use warnings;
use experimental qw(signatures);
use utf8;
use open qw(:std :encoding(UTF-8));

=head1 NAME

script/backfill-authors.pl - add author data to existing archives.yaml entries

=head1 SYNOPSIS

    perl script/backfill-authors.pl [archives.yaml]

=head1 DESCRIPTION

For every year/day already present in C<archives.yaml>, if the corresponding
POD article (C<YYYY/articles/YYYY-12-DD.pod>) exists, read its C<Author:>
header, canonicalize it (see L<PerlAdvent::Authors>), and add an C<author>
field to every entry emitted for that day.

Years/days with no POD on disk (2000-2010, most of 2021, 2026) are left
unchanged -- their entries simply get no author.

The rewrite is a line-oriented textual merge: it inserts C<, author: "...">
into each existing one-line entry so that all pre-existing fields and the
hand-authored formatting are preserved, keeping the diff reviewable.

Author headers are author-supplied DATA and are only parsed, never executed.

=cut

use FindBin;
use lib "$FindBin::Bin/../lib";
use PerlAdvent::Authors qw( parse_author_from_header canonical_author load_aliases );
use YAML::XS qw( LoadFile );

my $root     = "$FindBin::Bin/..";
my $archfile = $ARGV[0] // "$root/archives.yaml";
my $aliases  = load_aliases("$root/authors-aliases.yaml");

# Snapshot the pre-existing structure so we can verify the round-trip.
my ($before) = LoadFile($archfile);

# Read the raw file lines.
open my $in, '<', $archfile or die "Cannot open $archfile: $!";
my @lines = <$in>;
close $in;

# Cache of {year}{day} => canonical author (or undef when no author found).
my %author_for;

sub author_for ( $year, $day ) {
    return $author_for{$year}{$day} if exists $author_for{$year}{$day};

    my $file = sprintf '%s/%04d/articles/%04d-12-%02d.pod', $root, $year, $year, $day;
    my $author;
    if ( -e $file ) {
        open my $fh, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!";
        my $header = q{};
        while ( my $line = <$fh> ) {
            last unless $line =~ /\S/;
            $header .= $line;
        }
        close $fh;

        my $raw = parse_author_from_header($header);
        $author = defined $raw ? canonical_author( $raw, $aliases ) : undef;
    }

    return $author_for{$year}{$day} = $author;
}

my ( $cur_year, $cur_day );
my @out;

for my $line (@lines) {
    if ( $line =~ /^(\d{4}):\s*$/ ) {
        $cur_year = $1;
        $cur_day  = undef;
    }
    elsif ( $line =~ /^\s+(\d{1,2}):\s*$/ ) {
        $cur_day = $1 + 0;
    }
    elsif ( $line =~ /^\s*-\s*\{/ and defined $cur_year and defined $cur_day ) {
        my $author = author_for( $cur_year, $cur_day );
        if ( defined $author and length $author and $line !~ /\bauthor\s*:/ ) {
            my $safe = $author =~ s/"/\\"/gr;
            # Insert before the entry's closing brace, keeping trailing space.
            $line =~ s/\s*\}(\s*)$/, author: "$safe" }$1/;
        }
    }

    push @out, $line;
}

open my $tmp_fh, '>', "$archfile.tmp" or die "Cannot open $archfile.tmp: $!";
print {$tmp_fh} @out;
close $tmp_fh or die "Cannot close $archfile.tmp: $!";

# Verify the round-trip BEFORE replacing the original.
my ($after) = LoadFile("$archfile.tmp");
verify_intact( $before, $after );

rename "$archfile.tmp", $archfile or die "Cannot rename into place: $!";
say "Backfill complete; $archfile updated and verified.";

# Confirm every pre-existing module/topic/href value survived untouched.
sub verify_intact ( $before, $after ) {
    for my $year ( keys %$before ) {
        die "round-trip: year $year vanished\n" unless exists $after->{$year};
        for my $day ( keys $before->{$year}->%* ) {
            my $b = $before->{$year}{$day};
            # Some legacy days are YAML null (e.g. "17: ~") with no entries.
            next unless ref $b eq 'ARRAY';
            die "round-trip: $year/$day vanished\n"
                unless ref $after->{$year}{$day} eq 'ARRAY';
            my $a = $after->{$year}{$day};
            die "round-trip: $year/$day entry count changed\n"
                unless @$a == @$b;
            for my $i ( 0 .. $#$b ) {
                for my $field (qw( module topic href )) {
                    my $bv = $b->[$i]{$field} // next;
                    my $av = $a->[$i]{$field} // '';
                    die "round-trip: $year/$day [$i] $field changed "
                        . "('$bv' -> '$av')\n"
                        unless $av eq $bv;
                }
            }
        }
    }
    return 1;
}
