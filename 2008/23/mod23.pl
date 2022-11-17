use strict;
use warnings;
use Test::More;
use Data::Dumper;

use Test::Perl::Critic::Progressive ':all';

set_total_step_size(3);    # must remove 3 violations each run

set_step_size_per_policy(  # must remove at least one of those too
    'ValuesAndExpressions::ProhibitNoisyQuotes' => 1,
);

progressive_critic_ok();

# show summary of violations, beginning with the
# worst offender

my $file = get_history_file();

my %violation = %{ ${ do $file }[-1] };    # get last run

for (
    reverse sort { $violation{$a} <=> $violation{$b} }
    keys %violation
  ) {

    last unless $violation{$_};    # don't report policies with no violation

    diag sprintf "%3d %s\n", $violation{$_}, $_;

}

