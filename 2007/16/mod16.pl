#! perl -wl
use strict;
use warnings;
use DateTime;
use DateTime::TimeZone;


my $hour=3600;


my %Options=(year=>2007,
             month=>12,
	     day=>25,
	     hour=>00,
	     minute=>00,
	     second=>00,
	     # time_zone => 'Asia/Tapei',
	     );
my @TZNames=(
	'Pacific/Kiritimati', # GMT+14 start
	'Europe/London', # GMT+0 in winter
	'America/New_York',
	# GMT-11 ends the day 
	'US/Samoa',  # aka 'Pacific/Apia', 
	# as only uninhabited islands and ships in GMT-12 lately	
	# 'GMT-12' 
	);

my ($first,$lastD,$lastX);

foreach my $tzn (@TZNames) 
{
	my $xmas= DateTime->new(%Options,  time_zone => $tzn ,);
	my $offset=DateTime::TimeZone->new(name=>$tzn)
			->offset_for_datetime($xmas)
				/ $hour;
	$xmas->set_time_zone('GMT');
	$first ||= $xmas;
	my $dawn= DateTime->new(%Options,  time_zone => $tzn ,
			hour=>05)->set_time_zone('GMT');
	my $stst= DateTime->new(%Options,  time_zone => $tzn ,
			day=>26)->set_time_zone('GMT');  # begins St.Stephens or Boxing day
	$lastD= $dawn;
	$lastX= $stst;
	
	printf "\t%s:(UTC%+02d)\n\t\t     %sZ  00loc\n\t\t  to %sZ   5am \n\t\t(end %sZ +24)\n",
		$tzn, $offset, $xmas, $dawn, $stst;
}

printf "\n\tDeliveries \tfrom %sZ\n\t\t\t  to %sZ; \n\t\t\twhich is  %dD%02d:%02d\n",
	$first , $lastD,
	($lastD-$first)->in_units(qw(days hours minutes	));

printf "\tXmas somewhere populated \n\t\t\tfrom %sZ \n\t\t\t  to %sZ; \n\t\t\twhich is %dD%02d:%02d\n", 
	$first , $lastX,
	($lastX-$first)->in_units(qw(days hours minutes	));
