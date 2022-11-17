#!/usr/bin/perl

use strict;
use warnings;

use File::Find::Object;
use File::Basename;

my $pattern_str = shift;
my @dirs = @ARGV;

my $pattern = qr/$pattern_str/;

my $ff = File::Find::Object->new({}, @dirs);

my $result;
RESULTS_LOOP:
while (defined($result = $ff->next()))
{
    if (basename($result) =~ m{$pattern})
    {
        last RESULTS_LOOP;
    }
}

# Now we've exited from the loop and can do something with $result.

my @stat = stat($result);
print sprintf("Found the file \"%s\" of size %i, modified at %s\n",
    $result,
    $stat[7],
    scalar(localtime($stat[9]))
);
