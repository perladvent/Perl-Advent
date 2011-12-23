#!/usr/bin/env perl
use Config::General;
use Doll::O::Matic;
my $cfg_file = shift @ARGV || die "Please specify a config file!\n";


my $config = Config::General->new( 
				  -ConfigFile     => $cfg_file,
				  -SplitDelimiter => '\s*(?:\:|=|->)\s*|\s+',
				  -SplitPolicy    => 'custom',
);

my %doll_params = $config->getall();


my $doll_o_matic = Doll::O::Matic->new( \%doll_params );
my $doll = $doll_o_matic->make_doll() or die($doll_o_matic->error . "\n");

print "$doll is ready!\nPlease send to the giftwrapping station.\n";
