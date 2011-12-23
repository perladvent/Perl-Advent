use Benchmark 'cmpthese';
use Regexp::Keep;

#Pull out the regular expression compilation to test for overloading penalty
my $pstar = qr/(.*)\..*/;
my $kstar = qr/.*\K\..*/;
my $pplus = qr/(.+)\..*/;
my $kplus = qr/.+\K\..*/;
my $pnmbr = qr/(\w{3})\..*/;
my $knmbr = qr/\w{3}\K\..*/;

print "Keep:\n";
cmpthese(2_000_000,
	 {
	  behind=>sub{
	    # slow and inefficient
	    my $r = "abc.def.ghi.jkl";
	    $r =~ s/(?<=.{3})\..*//;
	  },
	  keep=>sub{
	    # fast and efficient
	    my $r = "abc.def.ghi.jkl";
	    $r =~ s/.{3}\K\..*//;
	  }
         }
	);

print "Star:\n";
cmpthese(2_000_000,
	 {
	  perlIN=>sub{
	    # slow and inefficient
	    my $r = "abc.def.ghi.jkl";
	    $r =~ s/(.*)\..*/$1/;
	  },
	  keepIN=>sub{
	    # fast and efficient
	    my $r = "abc.def.ghi.jkl";
	    $r =~ s/.*\K\..*//;
	  },
	  perlOUT=>sub{
	    # slow and inefficient
	    my $r = "abc.def.ghi.jkl";
	    $r =~ s/$pstar/$1/;
	  },
	  keepOUT=>sub{
	    # fast and efficient
	    my $r = "abc.def.ghi.jkl";
	    $r =~ s/$kstar//;
	  }
	 }
	);

print "\nPlus:\n";
cmpthese(2_000_000,
	 {
	  perlIN=>sub{
	    # slow and inefficient
	    my $r = "abc.def.ghi.jkl";
	    $r =~ s/(.+)\..*/$1/;
	  },
	  keepIN=>sub{
	    # fast and efficient
	    my $r = "abc.def.ghi.jkl";
	    $r =~ s/.+\K\..*//;
	  },
	  perlOUT=>sub{
	    # slow and inefficient
	    my $r = "abc.def.ghi.jkl";
	    $r =~ s/$pplus/$1/;
	  },
	  keepOUT=>sub{
	    # fast and efficient
	    my $r = "abc.def.ghi.jkl";
	    $r =~ s/$kplus//;
	  }
	 }
	);

print "\nNmbr:\n";
cmpthese(2_000_000,
	 {
	  perlIN=>sub{
	    # slow and inefficient
	    my $r = "abc.def.ghi.jkl";
	    $r =~ s/(\w{3})\..*/$1/;
	  },
	  keepIN=>sub{
	    # fast and efficient
	    my $r = "abc.def.ghi.jkl";
	    $r =~ s/\w{3}\K\..*//;
	  },
	  perlOUT=>sub{
	    # slow and inefficient
	    my $r = "abc.def.ghi.jkl";
	    $r =~ s/$pnmbr/$1/;
	  },
	  keepOUT=>sub{
	    # fast and efficient
	    my $r = "abc.def.ghi.jkl";
	    $r =~ s/$knmbr//;
	  }
	 }
	);
