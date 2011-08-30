#!perl -l
#
# teewt - backing tweets to CSV or, singly, as Dumper object
# 
# derived from Net::Twitter::Lite - OAuth desktop app example
# by William Ricker for Perl Advent Calendar 2010
# Copyright 2010 William Ricker
# License Same As Perl

use warnings;
use strict;

use Net::Twitter::Lite;
use File::Spec;
use Storable;
use Data::Dumper;
use Text::CSV;
use IO::Wrap; # wraphandle STDOUT
use feature ":5.10";

# Setup

my $nt = authorize();

# Supported Twitter API calls (methods) and columns to export in CSV
my %Fetches = (
	'sent_direct_messages' =>
                [ qw[ id_str created_at sender_screen_name recipient_screen_name text ]],
        'direct_messages' =>
                [ qw[ id_str created_at sender_screen_name recipient_screen_name text ]],
       'user_timeline' =>
                [qw[ created_at user/screen_name user/name user/id_str 
			text geo coordinates place id_str source
                      in_reply_to_status_id_str in_reply_to_screen_name retweet_count ]],
	'friends_timeline' =>
                [qw[ created_at user/screen_name user/name user/id_str 
		text geo coordinates place id_str
		in_reply_to_status_id_str in_reply_to_screen_name retweet_count ]],
);

my %Short = (
	sdms => {cmd=>'sent_direct_messages', all=>1},
	dms => {cmd=>'direct_messages', all=>1},
	mine => {cmd=>'user_timeline',all=>1},
	status =>  {cmd=>'user_timeline',one=>1},
	friends => {cmd=>'friends_timeline',all=>1},
	'last' => {cmd=>'friends_timeline',one=>1},
	sd1 => {cmd=>'sent_direct_messages', one=>1},
	dm1 => {cmd=>'direct_messages', one=>1},
);

# Work - look for commands on @ARGV

my $pages = $ENV{PAGES} || 50;

while ( my $cmd = shift ) {
    given ($cmd) {

	when (/PAGES=(\d+)/) {$pages = $1;}

	when (%Fetches){ all($cmd)} 

	when (%Short){
		my ($cmdLong,$one,$all) = @{$Short{$cmd}}{qw[cmd one all]};
		# hash slice per http://www.stonehenge.com/merlyn/UnixReview/col68.html 
 		once($cmdLong) if $one;
		all($cmdLong) if $all;
	}

	# last_$cmd is just one
	when ( / ^ last_ (\w+) (?(?{$Fetches{$1}})(?-:)|(*FAIL)) $ /xi ) {
	   once($1);
	}

	# alias - drop a final s and the last_ is optional
	when ( / ^ (?: last_ )? (\w+) (?(?{$Fetches{$1.q(s)}})(?-:)|(*FAIL)) $ /xi ) {
	   once($1.q(s));
	}

	when ( / ^ last = (?: (\d+) | (\w+) ) /xi ) {
	   once('user_timeline', {screen_name => $2} ) if $2;
	   once('user_timeline', {id => $1} ) if $1;

	}

	when ( / ^ user = (?: (\d+) | (\w+) ) /xi ) {
	   all('user_timeline', {screen_name => $2} ) if $2;
	   all('user_timeline', {id => $1} ) if $1;

	}

	default {
		warn "Unrecognized command $cmd \n supported choices:\n";
		warn "last_$_ $_ \n" for sort keys %Fetches ;
		warn "abbrevs: ".join(q( ),sort keys %Short )."\n";
		last;
	}
    }    # end given cmd
}    # end cmds

# ------------------ subs -------------------------

sub once {
    my ($meth, $args) = @_ ;
   my %args = $args ? %{$args} : () ; #=(screen_name => 'safety' | id => 123456 );
 
	#TBD should probably be in eval catch too ?
    my $status = $nt->$meth( { count => 1, %args } );
    print Dumper $status;
}

sub all {
    my ($meth, $args) = @_ ;
	# %Fetches is implicit arg
    my @Fields =  @{$Fetches{$meth}};

    my  $csv = Text::CSV->new ();
    my $io = wraphandle("STDOUT");

    # setup
    $csv->print ($io, \@Fields);
    @Fields = map { m((\w+)/(\w+)) ? [$1, $2] : $_ } @Fields;
	# expand 'user/screen_name' to qw[user screen_name] 
	# (avoids splitting in inner loop)

    my %args = $args ? %{$args} : () ; #=(screen_name => 'safety' | id => 123456 );

    for my $i ( 1 .. $pages )    # current 3200 max total fetch, so 50 pages enough
    {
        warn "fetching page $i ...\n"; # heartbeat

 	my $statuses; 
        eval {
           $statuses = $nt->$meth(
                {

                    # id => $friendId, # for others, on user_timeline
                    # since_id => $high_water, to filter already seen, on most
                    count => 100,    # typically 70..80 returned
                    page  => $i,     # from 1..
			%args,
                }
            );
        };    # end eval

        if ($@) {
            my $Err = $@;
            warn "$Err \n";
            given ($Err) {
                when (/502|503/) { sleep 1; redo };    # the intertubes were clogged
                default { die "Unexpected error $Err \n" };
            }
        }    # end if err
        my $ni = scalar @$statuses;
        warn "... got $ni \n"; # heartbeat
        last unless $ni;
        for my $status (@$statuses) {
              $csv->print ($io, 
			[ map {( ref $_ 
				? $status->{$_->[0]}->{$_->[1]} // "" #/
				:   $status->{$_} // "" #/
				) }  @Fields
			] ) ;
        } #end for each
    }    # end page i
}    # end sub all

sub authorize {

    # straight from Net-Twitter-Lite's examples/oauth_desktop.pl
    # just put into sub
    
    # You can replace the consumer tokens with your own;
    # these tokens are for the Net::Twitter example app.
    my %consumer_tokens = (
        consumer_key    => 'v8t3JILkStylbgnxGLOQ',
        consumer_secret => '5r31rSMc0NPtBpHcK8MvnCLg2oAyFLx5eGOMkXM',
    );

    # $datafile = oauth_desktop.dat
    my ( undef, undef, $datafile ) = File::Spec->splitpath($0);
    $datafile =~ s/\..*/.dat/;

    my $nt = Net::Twitter::Lite->new(%consumer_tokens);
    my $access_tokens = eval { retrieve($datafile) } || [];

    if (@$access_tokens) {
        $nt->access_token( $access_tokens->[0] );
        $nt->access_token_secret( $access_tokens->[1] );
    }
    else {
        my $auth_url = $nt->get_authorization_url;
        print " Authorize this application at: $auth_url\n"
		. "Then, enter the PIN# provided to continue: ";

        my $pin = <STDIN>;    # wait for input
        chomp $pin;

        # request_access_token stores the tokens in $nt AND returns them
        my @access_tokens = $nt->request_access_token( verifier => $pin );

        # save the access tokens
        store \@access_tokens, $datafile;
    }

    return $nt;
}

