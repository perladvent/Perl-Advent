use ForkBlock ':all';

#'Dumb' so that the parent can carry-on afterwards & show us another way
DumbFork {
    Parent \&manager,
    Child  \&worker
};

#OR
Fork {
    Parent {
      my $kid = $_[0];   #Not meant to condone infanticide
      local $SIG{ALRM} = sub { kill(9, $kid); sleep 2; exit };
      alarm(2);

      print "Work work work\n" while(1);
    }
    Child {
      print "I want toys!\n" while(1);
    }
};


sub manager{
  my $employee = $_[0];
  local $SIG{ALRM} = sub { kill(9, $employee); sleep 2; die };
  alarm(2);

  #Eval required to trap die, so signal handler can punt us,
  #and we can fall out to second invocation form.
  eval{ print "Work harder not smarter\n" while(1) };
}

sub worker{
  print "Work work work\n" while(1);
}
