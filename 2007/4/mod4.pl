use Test::More tests => 1;
use Test::Differences;

my $expected =
  { cookies => [qw(oatmeal lemondrop)], milk => [qw(whole chocolate)] };
my $got = { cookies => [qw(oatmeal lemondrop)], milk => [qw(skim chocolate)] };

eq_or_diff $got, $expected, "Stanta's treats";

$expected = "Baseball bat\nComic books\niPod\n";
$got      = "Baseball bat\nComic books\nZune\n";

eq_or_diff $got, $expected, 'x-mas list';
