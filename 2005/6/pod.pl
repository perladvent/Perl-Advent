use Interpolation name => \&function, ...;
print "la la la la $name{blah blah blah}";

# This is like doing:
$VAR = &function(blah blah blah);
print "la la la la $VAR";
