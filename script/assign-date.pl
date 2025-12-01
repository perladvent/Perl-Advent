#!/usr/bin/env perl

=head1 SYNOPSIS

    find 2024/incoming | fzf | xargs -I {} perl script/assign-date.pl --article {} --day 2

=head1 DESCRIPTION

Use the script to assign a post to a particular date.

=cut

use strict;
use warnings;
use feature qw( say state );

use DateTime        ();
use Getopt::Kingpin ();
use Path::Tiny qw( path );
my $kingpin = Getopt::Kingpin->new;
$kingpin->flags->get('help')->short('h');

#<<<
my $year =
    $kingpin->flag( 'year', 'Year: eg 2024' )
            ->short('y')
            ->default( DateTime->now->year )
            ->string;

my $day_of_month =
    $kingpin->flag( 'day', 'Publish day of month: eg 2' )
            ->required
            ->string;

my $article =
    $kingpin->flag( 'article', 'Article to assign: eg article/incoming/Foo.pod' )
            ->required
            ->string;
#>>>

$kingpin->parse;

my $target_date = DateTime->new(
    year  => "$year",
    month => 12,
    day   => "$day_of_month",
);
my $ymd              = $target_date->ymd;
my $publish_dir = path( $year, 'articles' );
$publish_dir->mkdir;

my $publish_location = $publish_dir->child( $ymd . '.pod' );

my $branch = 'publish/' . $ymd;

`git switch -c $branch`;
`git mv $article $publish_location`;
`git commit $article $publish_location -m "$ymd"`;
`git push`;
`gh pr create --title 'publish $ymd' --fill`;

say "This script does not automatically move images to $year/share/static";
say 'You will need to do this manually.'
