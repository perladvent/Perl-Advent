use Sub::Versive ':all';

#Unable to munge @_
prepend_to_sub{ print STDERR "Entering _bar(@_)...\n" } &There::_bar;
#Unable to access the sub's return value, "modify" it by returning
 append_to_sub{ print STDERR "Exiting _bar(@rv)...\n" } &There::_bar;

#Make a subroutine available everywhere via an unqualified name;
#this *must* happen after mungers have been installed
builtinify &There::foo;

foo(1,1,2,3);

package Here;
foo(99);

package There;
sub foo{
    _bar(@_);
}

sub _bar{
    print "baz quux\n";
    return 9;
}
