use Acme::Don't;

#The following does nothing
don't{
  print "Dear Santa,\n";
  printf("I want %i %s", int(1+9*rand), $_) foreach <DATA>;
  print "k thx luv janie\n"
}
__END__
ponies
puppies
ipods
