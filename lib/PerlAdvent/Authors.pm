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
    yaml_escape_dq
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

# Escape a string for safe emission as a YAML double-quoted scalar. Backslash
# MUST be escaped before the double-quote, and control/newline characters are
# neutralized so a value can never break the emitted archives.yaml line.
sub yaml_escape_dq ($str) {
    $str //= '';
    $str =~ s/\\/\\\\/g;         # backslash FIRST
    $str =~ s/"/\\"/g;           # then double-quote
    $str =~ s/[\x00-\x1f]/ /g;   # neutralize control/newline chars
    return $str;
}

1;
