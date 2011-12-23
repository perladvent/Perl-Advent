use enum qw(:LC_ Sec Min Hour MDay Mon Year WDay YDay IsDST);
use enum qw(:Months_ Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
print "Happy New Year!!\n" if (localtime)[LC_Mon] == Months_Jan &&
  (localtime)[LC_MDay] == 1;

use enum::hash 'enum';
%LC    = enum qw(Sec Min Hour MDay Mon Year WDay YDay Isdst);
%month = enum qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
print "Happy New Year!!\n" if (localtime)[$LC{Mon}] == $month{Jan} &&
  (localtime)[$LC{MDay}] == 1;
