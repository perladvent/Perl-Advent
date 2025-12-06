#!/usr/bin/env perl

=head1 SYNOPSIS

    find $(perl -E 'say 1900+(localtime)[5]')/incoming | fzf | xargs -I {} perl script/assign-date.pl --article {} --day 2

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

# Find and move files (images, audio, etc.) referenced in the article
my @moved_files = find_and_move_files( $article, $year );

my $branch = 'publish/' . $ymd;

# Create worktree directory if it doesn't exist
my $worktrees_dir = path('.worktrees');
$worktrees_dir->mkdir unless $worktrees_dir->exists;

# Set up worktree path
my $worktree_path = $worktrees_dir->child($ymd);

# Create worktree if it doesn't exist
if ( !$worktree_path->exists ) {
    # Check if branch exists
    my $branch_exists = system("git rev-parse --verify $branch >/dev/null 2>&1") == 0;

    if ($branch_exists) {
        say "Creating worktree for existing branch $branch";
        system("git worktree add $worktree_path $branch");
    }
    else {
        say "Creating worktree with new branch $branch";
        system("git worktree add -b $branch $worktree_path");
    }
}
else {
    say "Using existing worktree at $worktree_path";
}

# Change to worktree directory
chdir $worktree_path or die "Cannot chdir to $worktree_path: $!";

`git mv $article $publish_location`;

# Add moved files to git
for my $file (@moved_files) {
    `git add $file`;
}

my @files_to_commit = ( $article, $publish_location, @moved_files );
my $commit_cmd = 'git commit ' . join( ' ', map { qq{"$_"} } @files_to_commit ) . qq{ -m "$ymd"};
`$commit_cmd`;
`git push`;
`gh pr create --title 'publish $ymd' --fill`;

my @existing_files = find_existing_files( $publish_location, $year );

if (@moved_files) {
    say "Moved " . scalar(@moved_files) . " file(s) to $year/share/static:";
    say "  - $_" for @moved_files;
}
else {
    say "No files found to move.";
}

if (@existing_files) {
    say "Found " . scalar(@existing_files) . " file(s) already in $year/share/static:";
    say "  - $_" for @existing_files;
}

say "\nWorktree created at: $worktree_path";
say "To switch to this worktree: cd $worktree_path";

sub find_and_move_files {
    my ( $article_path, $year ) = @_;

    my $article_file = path($article_path);
    return unless $article_file->exists;

    my $content      = $article_file->slurp_utf8;
    my $incoming_dir = $article_file->parent;
    my $static_dir   = path( $year, 'share', 'static' );
    $static_dir->mkpath;

    my @moved_files;

    # Get all non-POD files in the incoming directory
    my @potential_files = grep { $_->is_file && $_->basename !~ /\.pod$/ } $incoming_dir->children;

    for my $file (@potential_files) {
        my $filename = $file->basename;

        # Check if this file is referenced in the article
        if ( $content =~ /\Q$filename\E/ ) {
            my $dest_file = $static_dir->child($filename);

            # Use git mv to move the file
            my $cmd = qq{git mv "$file" "$dest_file"};
            `$cmd`;

            if ( $? == 0 ) {
                push @moved_files, $dest_file->stringify;
                say "Found and moved: $filename";
            }
            else {
                warn "Failed to move $filename: $!";
            }
        }
    }

    return @moved_files;
}

sub find_existing_files {
    my ( $article_path, $year ) = @_;

    my $article_file = path($article_path);
    return unless $article_file->exists;

    my $content    = $article_file->slurp_utf8;
    my $static_dir = path( $year, 'share', 'static' );
    return unless $static_dir->exists;

    my @existing_files;

    # Get all files in the static directory
    my @static_files = grep { $_->is_file } $static_dir->children;

    for my $file (@static_files) {
        my $filename = $file->basename;

        # Check if this file is referenced in the article
        if ( $content =~ /\Q$filename\E/ ) {
            push @existing_files, $file->stringify;
        }
    }

    return @existing_files;
}
