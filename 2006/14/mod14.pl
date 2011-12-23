use strict;
use warnings;
use IPC::Run3;

my($in, $out, $err) = ("merry\nxmas\n");
my @cmd =
  (q{perl -e 'print scalar <STDIN>; print STDERR scalar <STDIN>; exit 42;'});

eval {
  run3(@cmd, \$in, \$out, \$err);
};

if($@) {
  die "Something bad happened: $@\n";
}

if($?) {
  printf "Exit code indicates problems: %i\n", $?>>8;
}

s/\n/\\n/g foreach($in, $out, $err);
print "IN: $in\nOUT: $out\nERR: $err\n";
