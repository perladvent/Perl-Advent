use Module::ScanDeps;

my $hash_ref = scan_deps( @ARGV ); # shorthand; assume recurse == 1

open FILE, '<', '02packages.details.txt' or die 'need package info file';
my %mod2author = map {
		my ($m,$v,$d) = split ' ', $_;
		my $author = (split '/', $d)[2];
		$m => $author
	} grep { (/^$/ .. 0) && /\S/ }
	<FILE>;

my %authors;
foreach my $mod ( values %$hash_ref ){
  next unless $mod->{type} eq 'module';
  my %uses = map { $_ => 1 } @{ $mod->{uses} || [] };

  my $key = $mod->{key};
  $key =~ s#\.pm$##;
  $key =~ s#/#::#g;
  my $author = $mod2author{$key} || 'unknown';

  $authors{$author} ||= { author => $author };
  $authors{$author}->{naughty}++ if ! ( $uses{'strict.pm'} || $uses{'warnings.pm'} );
  $authors{$author}->{nice}++    if     $uses{'strict.pm'} && $uses{'warnings.pm'}  ;
}

my @naughty = map { $_->{author} } grep { $_->{naughty}                 } values %authors;
my @nice    = map { $_->{author} } grep { $_->{nice} && ! $_->{naughty} } values %authors;
print "Authors that have been nice (Red Ryder):\n", map {"\t$_\n" } @nice;
print "\n";
print "Authors that have been naughty (coal):\n",   map {"\t$_\n" } @naughty;
