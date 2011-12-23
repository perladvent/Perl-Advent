# -*- perl -*-
#
# Package::Alias - Alias one namespace into another
#
# $Id: Alias.pm,v 2.1 2009/12/01 16:01:28 jpierce Exp $

package Package::Alias;
use strict qw/vars subs/;
use vars   qw/$VERSION $DEBUG $BRAVE/;
use Carp;

$VERSION     = 0.11_1;
$DEBUG       = 0;

#------------------------------------------------------------
# Class Methods
#------------------------------------------------------------

sub alias {
    my $class_or_self = shift;
    my %args  = @_;

    while ( my ( $alias, $orig ) = each %args ) {

	if ( scalar keys %{$alias . "::" } && ! $BRAVE ) {
	    carp "Cowardly refusing to alias over '$alias' because it's already in use";
	    next;
	}

	*{$alias . "::"} = \*{$orig . "::"};
	print STDERR __PACKAGE__ . ": aliasing '$alias' => '$orig'\n"
	    if $DEBUG;
    }
}


sub import {
    my $class_or_self = shift;
    my %args  = @_;

    while ( my ( $alias, $orig ) = each %args ) {
	my($alias_pm, $orig_pm) = ($alias, $orig);
	foreach( $alias_pm, $orig_pm ){
	    s/::/\//g;
	    $_ .= '.pm';
	}

	next if exists($INC{$alias_pm});
	my $caller = caller;
	eval "{package $caller; use $orig;}";
	confess $@ if $@;
	$INC{$alias_pm} = $INC{$orig_pm};
    }

    alias($class_or_self, @_);
}

1;

__END__

#------------------------------------------------------------
# Docs
#------------------------------------------------------------

=head1 NAME

Package::Alias - alias one namespace into another

=head1 SYNOPSIS

  use Package::Alias Foo    => 'main',
		     'P::Q' => 'Really::Long::Package::Name',
		     Alias  => 'Existing::Namespace';

  BEGIN{
    use Package::Alias Moose => Mouse;

    #Make Mouse's finicky internal checks happy...
    Moose::Exporter->setup_import_methods(exporting_package=>'Moose',

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

=head1 DESCRIPTION

This module aliases one package name to another. After running the
SYNOPSIS code,  C<@INC> (shorthand for C<@main::INC>) and C<@Foo::INC>
reference the same memory, likewise for the other pairings.

To facilitate some crafty slight of hand, the above will also
C<use P::Q> if it's not already loaded, and tell Perl that
C<Really::Long::Package::Name> is loaded. In some rare cases
such as C<Mouse>, additional trickery may be required...

=head1 GLOBALS

Package::Alias won't, by default, alias over a namespace if it's
already in use. That's not considered a fatal error - you'll just get
a warning and flow will continue. You can change that cowardly
behaviour this way:

  # Make Bar like Foo, even if Bar is already in use.

  BEGIN { $Package::Alias::BRAVE = 1 }

  use Package::Alias Bar => 'Foo';

=head1 CAVEATS

To be strict-compliant, you'll need to quote any packages on the
left-hand side of a => if the namespace has colons. Packages on the
right-hand side all have to be quoted. This is documented as
L<perlop/"Comma Operator">.

=head1 NOTES

Chip Salzenberg says that it's not technically feasible to perform
runtime namespace aliasing.  At compile time, Perl grabs pointers to
functions and global vars.  Those pointers aren't updated if we alias
the namespace at runtime.

=head1 AUTHOR

Joshua Keroes <skunkworks@eli.net>

Jerrad Pierce <jpierce@cpan.org>

=head1 SEE ALSO

L<Devel::Symdump>

=cut
