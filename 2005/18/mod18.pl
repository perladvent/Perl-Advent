use Regexp::Assemble;

foreach( 0 .. 1){
  my $ra = new Regexp::Assemble(mutable=>$_);
  $ra->add(qw'popcorn tinsel lights candles nutcrackers ornaments');
  isDone($ra);
}

sub isDone{
  my $ra = shift;

  printf "Tree Trimmings:\n\t%s\n\n", $ra->re();

  if( $ra->re() !~ "star" ){
    warn "Doh! We forgot to top the tree!\n";
    $ra->add('star');
    isDone($ra);
  }
  else{
    warn("Light'er up!\n");
  }
}
