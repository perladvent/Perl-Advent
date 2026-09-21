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

For years/days with no modern POD on disk, a LEGACY source is consulted:

=over

=item * B<2000-2004> are attributed to B<Mark Fowler> by editorial decision.
The founder wrote these years (see C<2000/about.html>, first-person); there is
no per-article byline, so this is a documented MANUAL attribution, not an
extracted one.

=item * B<2005> is left author-less: the spod5 slideshows carry no reliable
per-article byline, so these entries stay unattributed.

=item * B<2006-2010> have their real byline extracted from the legacy HTML
(C<< <h3>by NAME</h3> >>), falling back to C<=for advent_author> in an adjacent
legacy POD. Refresh-stub C<index.html> files (Padded/Ordinal/Catsup redirects)
and missing days yield no author.

=back

Any remaining years/days with no source (most of 2021, 2026, missing legacy
days) are left unchanged -- their entries simply get no author.

The rewrite is a line-oriented textual merge: it inserts C<, author: "...">
into each existing one-line entry so that all pre-existing fields and the
hand-authored formatting are preserved, keeping the diff reviewable.

Author headers are author-supplied DATA and are only parsed, never executed.

=cut

use FindBin;
use lib "$FindBin::Bin/../lib";
use PerlAdvent::Authors qw(
    parse_author_from_header
    canonical_author
    load_aliases
    legacy_article_path
    parse_legacy_byline
    parse_advent_author_tag
);
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
    my $raw;
    if ( -e $file ) {
        open my $fh, '<:encoding(UTF-8)', $file or die "Cannot open $file: $!";
        my $header = q{};
        while ( my $line = <$fh> ) {
            last unless $line =~ /\S/;
            $header .= $line;
        }
        close $fh;
        $raw = parse_author_from_header($header);
    }
    else {
        $raw = legacy_raw_author( $year, $day );
    }

    my $author = defined $raw ? canonical_author( $raw, $aliases ) : undef;
    return $author_for{$year}{$day} = $author;
}

# Read a file as raw bytes; returns undef if it cannot be opened. Legacy
# bylines are ASCII, so no decode layer is needed (and none is imposed, to
# avoid warnings on non-UTF-8 legacy bytes elsewhere in the file).
sub slurp ($path) {
    open my $fh, '<:raw', $path or return undef;
    local $/;
    return scalar <$fh>;
}

# Resolve the raw (pre-canonical) author for a legacy (pre-2011) day, or undef.
# See this script's DESCRIPTION for the per-era routing. All text handled here
# is author-supplied DATA and is only parsed, never executed.
sub legacy_raw_author ( $year, $day ) {

    # 2000-2004: documented editorial attribution to the founder (no byline).
    return 'Mark Fowler' if $year >= 2000 && $year <= 2004;

    # 2005: spod5 slideshows have no reliable byline; leave unattributed.
    return undef if $year == 2005;

    # 2006-2010: extract the real byline; anything else stays unattributed.
    return undef unless $year >= 2006 && $year <= 2010;

    my $file = "$root/" . legacy_article_path( $year, $day );
    return undef unless -e $file;

    my $html = slurp($file);
    return undef unless defined $html;

    # Skip refresh-stub index.html files (Padded/Ordinal/Catsup redirects).
    return undef if $html =~ m{<title>[^<]*\bredirect\b[^<]*</title>}i;

    my $raw = parse_legacy_byline($html);
    return $raw if defined $raw;

    # Fallback: an adjacent legacy POD's `=for advent_author NAME`.
    my $n = $day + 0;
    for my $pod ( sort glob "$root/$year/$n/*.pod" ) {
        my $pod_text = slurp($pod) // next;
        my $tag = parse_advent_author_tag($pod_text);
        return $tag if defined $tag;
    }

    return undef;
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
