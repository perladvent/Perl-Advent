#!/pro/bin/perl

use 5.16.2;
use warnings;

use Data::Peek;
binmode STDERR, ":encoding(utf-8)";

use Text::CSV_XS qw( csv );

DDumper csv (in => "wish-uk.csv", headers => "auto");
