#!/usr/bin/perl

use DBI;

# My files are laid out like this:
#
# presents.txt
# person_no|present
# 1|bicycle
# 1|action figure
# 2|doll
# 3|doll
# 4|bicycle
#
# people.txt
# person_no|name|personality|address
# 1|bob smith|nice|123 anywhere st, St. Petersburg
# 2|alice andrews|nice|465 somewhere st, Moscow
# 3|frank martonick|naughty|1138 lenin ave, St. Petersburg
# 4|billy cutter|nice|31337 peoples lane, Moscow

my $dbh = DBI->connect('dbi:AnyData(RaiseError=>1):');

$dbh->func( 'people', 'Pipe', '/home/norrish/lists/people.txt', 'ad_import');
$dbh->func( 'presents', 'Pipe', '/home/norrish/lists/presents.txt', 'ad_import');

my $sth = $dbh->prepare(q/
        SELECT person_no, name, address
            FROM people
          WHERE personality = ?/);

$sth->execute('nice');

while ( my $person = $sth->fetchrow_arrayref ) {
    my $presents = $dbh->selectall_arrayref(q/
                SELECT present
                    FROM presents
                  WHERE person_no = ?/, {}, $person->[0]);

    print "Presents for ". $person->[1] . " (living at: ". $person->[2] . ")\n\t",
          join("\n\t", map { join " ", @$_ } @$presents), "\n\n";
}

$dbh->disconnect();
