#!/usr/bin/perl;

use Logfile::Rotate;

my @logs = map {
    my $file = $_;
    Logfile::Rotate->new(
        File => $file,
        Gzip => 'lib',
        Dir => '/var/logs/dev.old',
        Post => sub { unlink $file } ); } </var/logs/dev/*.log>;

for (@logs) { $_->rotate() }

