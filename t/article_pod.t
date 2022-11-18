#!/usr/bin/env perl
use v5.26;
use open qw(:std :encoding(UTF-8));
use experimental qw(signatures);

use Test::More;

=head NAME

t/article_pod.t - check the Perl Advent articles' headers and pod

=head1 SYNOPSIS

	% prove t/article_pod.t

	% perl t/article_pod.t file1 file2 ...

=head1 DESCRIPTION

=head1 AUTHOR

brian d foy, bdfoy@cpan.org

=head1 COPYRIGHT

Copyright © 2022, brian d foy. All rights reserved.

=head1 LICENSE

Whatever the license is for https://github.com/perladvent/Perl-Advent

=cut

unless( @ARGV ) {
	# most years don't do the pod stuff the way we do it now
	# make fancier later
	my $y = join ',', 2011 .. 2022;
	@ARGV = glob( "{$y}/articles/*.pod" );
	push @ARGV, glob( "{$y}/incoming/*.pod");
	}

foreach my $path ( @ARGV ) {
	my( $header, $pod ) = split_text( read_text($path) )->@*;

	subtest $path => sub {
		subtest "header for $path" => sub { check_header( $header ) };
		subtest "pod for $path"	   => sub { check_pod( $pod ) };
		};
	}

done_testing();


sub check_header ( $header ) {
	state @required = qw(title topic author);
	my %lines =
		map { my @a = split /:/, $_, 2; $a[0] = lc($a[0]); @a }
		split /\R/, $header;

	foreach my $field ( @required ) {
		ok( exists $lines{$field}, "Required field <$field> is there" );
		}
	}

# Mostly stolen from Test::Pod
sub check_pod ( $pod ) {
	state $rc = require Pod::Simple;
	my $checker = Pod::Simple->new;

	my $name = "Pod checks passes";

	$checker->output_string( \my $trash ); # Ignore any output

	$checker->parse_string_document( $pod );

	my $ok = !$checker->any_errata_seen;
	$name .= ' (no pod)' if !$checker->content_seen;

	ok( $ok, $name );

	if ( !$ok ) {
		my $lines = $checker->{errata};
		for my $line ( sort { $a<=>$b } keys %$lines ) {
			my $errors = $lines->{$line};
			diag( "line $line: $_" ) for @$errors;
		}
	}

	return $ok;
	}

sub read_text ( $path ) {
	my $article_text = do { local( @ARGV, $/ ) = $path; <<>> };
	}

sub split_text ( $text ) { [ split /\R{2}/, $text, 2 ] }
