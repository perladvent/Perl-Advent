package Any::Moose::Forcefully;
BEGIN{
    use Package::Alias Moose => Mouse;

    #Make Mouse's finicky internal checks happy...
    Mouse::Exporter->setup_import_methods(
					  exporting_package=>'Moose',
					  
					  #Alas the defaults live in Mouse...
					  as_is => [qw(
							extends with
							has
							before after around
							override super
							augment  inner
						     ),
						\&Scalar::Util::blessed,
						    \&Carp::confess,
						   ],
					 );
    #Otherwise we get
    #The package Moose package does not use Mouse::Exporter at
    #  /usr/local/share/perl/5.10.0/Mouse/Exporter.pm line 140
    #    Mouse::Exporter::do_import('Moose') called at mod1.pl line 23
    #    Reindeer::BEGIN() called at mod1.pl line 23
    #    eval {...} called at mod1.pl line 23
    #BEGIN failed--compilation aborted at mod1.pl line 23.
}

1;
