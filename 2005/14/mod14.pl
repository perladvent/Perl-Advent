#! /usr/bin/env perl  -l
use strict;
use warnings;
use Carp;
use HTML::Lint;

my $file_name;
my ($total_count, $n_files)=(0,0);

while ($file_name = shift @ARGV) {

	open my $input, '<', $file_name 
		or croak "Can not open script for read";
	my $data = do { local $/; <$input> };  		 # slurp!
	close $input; 
	$n_files++;

	my $lint = HTML::Lint->new;
	    # $lint->only_types( HTML::Lint::STRUCTURE );

	    $lint->parse( $data );
	    # $lint->parse_file( $filename );

	    my $error_count = $lint->errors;
	    carp "Uh oh, $error_count errors found in $file_name."
		if $error_count; 

	    foreach my $error ( $lint->errors ) {
		print $error->as_string;
	    }
}

print "$total_count errors found in $n_files processed";

