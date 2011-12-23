#!/usr/bin/perl

use strict;
use warnings;

use Shell qw(svnadmin tar du mutt touch);
use File::Slurp qw(read_file write_file);
use File::Path qw(rmtree);

# the repository location
my $ROOT = '/usr/share/svnroot/'; 
# where I send the backup to
my $EMAIL = 'backup-sink@example.com';
# control file: the last backup time
my $CTL = glob '~/bk-time'; 

my $LAST_MARK = -e $CTL ? read_file($CTL) : 0;
my $PERIOD = 24*60*60; # 24 hours 
my $NOW = time;

if ($NOW>$LAST_MARK+$PERIOD) { # more than $PERIOD later
  my $TMP = 'svnbak';
  # backing up the repository
  svnadmin("hotcopy", $ROOT, $TMP);
  # archiving/compressing
  my $BAK = "$TMP.tar.bz2";
  tar("cfj", $BAK, $TMP);

  my $SUBJECT = "[ATTIC] backup of $ROOT";
  my $BODY = sprintf <<BODY, scalar localtime, -s $BAK, du("-hs", $ROOT);
$ROOT: backup at %s
  %d Bytes - $BAK
  %s       (uncompressed)
BODY
  write_file('body.txt', $BODY);
  mutt("-s", $SUBJECT, "-a", $BAK, $EMAIL, '<', 'body.txt'); # sending mail

  rmtree($TMP);
  unlink $BAK or warn "could not rm '$BAK': $!\n"; 
  unlink 'body.txt' or warn "could not rm 'body.txt': $!\n"; 

  my $MARK = int($NOW / $PERIOD) * $PERIOD;
  write_file($CTL, $MARK);

} else {
  # don't do anything but
  touch($CTL); # update timestamp
}
