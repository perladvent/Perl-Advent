package PerlAdvent::Authors;
use v5.26;
use warnings;
use experimental qw(signatures);
use utf8;

use Exporter 'import';
our @EXPORT_OK = qw(
    parse_author_from_header
    display_name
    normalize_key
    load_aliases
    canonical_author
    decode_legacy_entities
    parse_legacy_byline
    parse_advent_author_tag
    legacy_article_path
);

=head1 NAME

PerlAdvent::Authors - shared helpers for extracting and normalizing article
author names.

=head1 DESCRIPTION

The C<Author:> headers in Perl Advent POD articles are free-form,
author-supplied data. They may be C<Name E<lt>emailE<gt>>, C<Name (email)>,
name-only, email-only, contain embedded quotes, or use UTF-8. This module
centralizes the logic to turn such a header into a canonical display name
suitable for grouping articles by author.

All input is treated strictly as DATA. Nothing here evaluates or executes any
part of a header value.

=cut

# Parse the raw value of the (case-insensitive) `author` key out of a POD
# header block. Returns the raw value string, or undef if there is no author
# header. Mirrors the repo's canonical header-parse idiom.
sub parse_author_from_header ($header_text) {
    return undef unless defined $header_text;

    my %lines =
        map { my @a = split /:/, $_, 2; $a[0] = lc( $a[0] // q{} ); @a }
        split /\R/, $header_text;

    my $raw = $lines{author};
    return undef unless defined $raw;

    $raw =~ s/^\s+|\s+$//g;
    return length $raw ? $raw : undef;
}

# Turn a raw Author value into a display NAME: strip a trailing <...> or
# (...) email, trim, and collapse internal whitespace. If nothing remains
# (email-only header), fall back to the raw value (the email itself).
sub display_name ($raw) {
    return undef unless defined $raw;

    my $name = $raw;
    $name =~ s/\s*<[^<>]*>\s*$//;     # trailing <email>
    $name =~ s/\s*\([^()]*\)\s*$//;   # trailing (email)
    $name =~ s/^\s+|\s+$//g;
    $name =~ s/\s+/ /g;               # collapse internal whitespace

    # Email-only header (nothing left after stripping): use the raw value,
    # whitespace-collapsed, as the name.
    unless ( length $name ) {
        $name = $raw;
        $name =~ s/^\s+|\s+$//g;
        $name =~ s/\s+/ /g;
    }

    return $name;
}

# A grouping key that merges case/spacing variants of the same display name.
sub normalize_key ($name) {
    return q{} unless defined $name;
    my $key = $name;
    $key =~ s/^\s+|\s+$//g;
    $key =~ s/\s+/ /g;
    return fc $key;
}

# Load authors-aliases.yaml: a map of variant-string -> canonical display
# name. Returns {} if the file is absent. The returned map is keyed by the
# normalized form of each variant so lookups are case/spacing insensitive.
sub load_aliases ($path) {
    return {} unless defined $path and -e $path;

    require YAML::XS;
    my ($data) = YAML::XS::LoadFile($path);
    return {} unless ref $data eq 'HASH';

    my %aliases;
    for my $variant ( keys %$data ) {
        my $canonical = $data->{$variant};
        next unless defined $canonical and length $canonical;
        $aliases{ normalize_key($variant) } = $canonical;
    }
    return \%aliases;
}

# Tie it together: from a raw Author value, produce the final display name to
# use for both grouping and display. Aliases are matched against both the raw
# value and the derived display name (normalized).
sub canonical_author ( $raw, $aliases = {} ) {
    return undef unless defined $raw;

    if ( ref $aliases eq 'HASH' and %$aliases ) {
        if ( defined( my $hit = $aliases->{ normalize_key($raw) } ) ) {
            return $hit;
        }
    }

    my $name = display_name($raw);

    if ( ref $aliases eq 'HASH' and %$aliases ) {
        if ( defined( my $hit = $aliases->{ normalize_key($name) } ) ) {
            return $hit;
        }
    }

    return $name;
}

=head1 LEGACY (2000-2010) HELPERS

The pre-2011 calendars have no modern POD article with an C<Author:> header.
For 2006-2010 the author appears as a byline in the generated legacy HTML
(C<< <h3>by NAME</h3> >>), sometimes only in an adjacent legacy POD as
C<=for advent_author NAME>. These helpers extract that DATA; nothing here is
executed. Names are HTML-entity-decoded, trimmed, and whitespace-collapsed.
Co-authored bylines (C<A & B>) are kept as a single string, matching how the
modern code treats multi-author headers.

=cut

# Decode the handful of HTML entities that appear in legacy bylines, including
# the double-encoded &amp;amp;. Uses HTML::Entities when available (decoding
# twice to collapse double-encoding), else a small inline table.
sub decode_legacy_entities ($s) {
    return $s unless defined $s;

    if ( eval { require HTML::Entities; 1 } ) {
        $s = HTML::Entities::decode_entities($s);
        $s = HTML::Entities::decode_entities($s);
        return $s;
    }

    $s =~ s/&amp;amp;/&/g;    # double-encoded ampersand first
    $s =~ s/&#39;/'/g;
    $s =~ s/&quot;/"/g;
    $s =~ s/&lt;/</g;
    $s =~ s/&gt;/>/g;
    $s =~ s/&amp;/&/g;
    return $s;
}

# Extract a byline from legacy article HTML: the (case-insensitive) pattern
# <h3 ...>by NAME</h3>. Tag case varies. Returns the decoded, trimmed,
# whitespace-collapsed name, or undef.
sub parse_legacy_byline ($html) {
    return undef unless defined $html;
    return undef unless $html =~ m{<h3[^>]*>\s*by\s+(.+?)\s*</h3>}is;

    my $name = decode_legacy_entities($1);
    $name =~ s/^\s+|\s+$//g;
    $name =~ s/\s+/ /g;
    return length $name ? $name : undef;
}

# Extract an author from a legacy POD's `=for advent_author NAME` line.
# Returns the decoded, trimmed, whitespace-collapsed name, or undef.
sub parse_advent_author_tag ($pod) {
    return undef unless defined $pod;
    return undef unless $pod =~ /^=for\s+advent_author\s+(.+)$/m;

    my $name = decode_legacy_entities($1);
    $name =~ s/^\s+|\s+$//g;
    $name =~ s/\s+/ /g;
    return length $name ? $name : undef;
}

# The English ordinal suffix for a day number (1 -> st, 2 -> nd, 3 -> rd,
# 4..20 -> th, 21 -> st, ...).
sub _ordinal_suffix ($n) {
    return 'th' if ( $n % 100 ) >= 11 && ( $n % 100 ) <= 13;
    my %suffix = ( 1 => 'st', 2 => 'nd', 3 => 'rd' );
    return $suffix{ $n % 10 } // 'th';
}

# The expected relative path (from the repo root) to a legacy day's article
# HTML. 2001-2004 use an ordinal directory (e.g. 2003/10th/index.html);
# every other legacy year uses the integer directory (e.g. 2008/7/index.html).
# $day may be zero-padded ("07") or an integer.
sub legacy_article_path ( $year, $day ) {
    my $n = $day + 0;
    if ( $year >= 2001 && $year <= 2004 ) {
        return sprintf '%d/%d%s/index.html', $year, $n, _ordinal_suffix($n);
    }
    return sprintf '%d/%d/index.html', $year, $n;
}

1;
