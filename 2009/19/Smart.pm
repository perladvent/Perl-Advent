package Match::Smart;

use 5.006;
use strict;
use warnings;

use Carp;
use Scalar::Util qw/ looks_like_number refaddr /;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(smart_match given when default) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '1.01';

## initialize match look-up constants

my $i;

use constant ARRAY  => ++$i;
use constant CODE   => ++$i;
use constant HASH   => ++$i;
use constant NUMBER => ++$i;
use constant OBJECT => ++$i;
use constant REF    => ++$i;
use constant REGEXP => ++$i;
use constant SCALAR => ++$i;
use constant STRING => ++$i;
use constant UNDEF  => ++$i;

## type constant to name mappings

my @type_names;

$type_names[ARRAY]  = 'ARRAY';
$type_names[CODE]   = 'CODE';
$type_names[HASH]   = 'HASH';
$type_names[NUMBER] = 'NUMBER';
$type_names[OBJECT] = 'OBJECT';
$type_names[REF]    = 'REF';
$type_names[REGEXP] = 'REGEXP';
$type_names[SCALAR] = 'SCALAR';
$type_names[STRING] = 'STRING';
$type_names[UNDEF]  = 'UNDEF';

## assemble look-up table for matching subs

my @match_subs;

$match_subs[ARRAY ][ARRAY ] = sub { 
  my $count = scalar @{$_[0]};
  return 0 unless $count == scalar @{$_[1]};

  for(my $i=0; $i<$count; $i++){
    return 0 unless _smart_match($_[0][$i], $_[1][$i], $_[2]);
  }
  return 1;
};
#Based on perlsyn it's unclear whether this should be grep or short-circuiting
$match_subs[ARRAY ][CODE  ] = sub { !grep { !$_[1]->($_) } @$_[0] };
$match_subs[ARRAY ][HASH  ] = sub {
   for my $v (@{$_[0]}) {
      return 1 if exists $_[1]->{$v}
   }
   return;
};
$match_subs[ARRAY ][NUMBER] = sub {
   for my $v (@{$_[0]}) {
      return 1 if _smart_match($v, $_[1], $_[2]);
   }
   return;
};
$match_subs[ARRAY ][OBJECT] = sub {
   for my $v (@{$_[0]}) {
      return 1 if _smart_match($v, $_[1], $_[2]);
   }
   return;
};
$match_subs[ARRAY ][REF   ] = sub { _smart_match($_[0], ${$_[1]}, $_[2]) };
$match_subs[ARRAY ][REGEXP] = sub {
   for my $v (@{$_[0]}) {
      return 1 if _smart_match($v, $_[1], $_[2]);
   }
   return;
};
$match_subs[ARRAY ][SCALAR] = sub { _smart_match($_[0], ${$_[1]}, $_[2]) };
$match_subs[ARRAY ][STRING] = sub {
   for my $v (@{$_[0]}) {
      return 1 if _smart_match($v, $_[1], $_[2]);
   }
   return;
};
$match_subs[ARRAY ][UNDEF ] = sub {
   for my $v (@{$_[0]}) {
      return 1 if _smart_match($v, $_[1], $_[2]);
   }
   return;
};

#Swapped order of code-code to match 5.10 perlsyn && dox
$match_subs[CODE  ][CODE  ] = sub { $_[1]->(&{$_[0]}) };
#Based on perlsyn it's unclear whether this should be grep or short-circuiting
$match_subs[CODE  ][HASH  ] = sub { !grep { !$_[0]->($_) } keys %{$_[1]} };
$match_subs[CODE  ][NUMBER] = sub { $_[0]->($_[1]) };
$match_subs[CODE  ][OBJECT] = sub { $_[0]->($_[1]) };
$match_subs[CODE  ][REF   ] = sub { _smart_match($_[0], ${$_[1]}, $_[2]) };
$match_subs[CODE  ][REGEXP] = sub { $_[0]->($_[1]) };
$match_subs[CODE  ][SCALAR] = sub { _smart_match($_[0], ${$_[1]}, $_[2]) };
$match_subs[CODE  ][STRING] = sub { $_[0]->($_[1]) };
$match_subs[CODE  ][UNDEF ] = sub { $_[0]->($_[1]) };

$match_subs[HASH  ][HASH  ] = sub {
  "@{[sort keys %{$_[0]}]}" eq "@{[sort keys %{$_[1]}]}";
};
$match_subs[HASH  ][NUMBER] = sub { $_[0]->{$_[1]} };
$match_subs[HASH  ][OBJECT] = undef;
$match_subs[HASH  ][REF   ] = sub { _smart_match($_[0], ${$_[1]}, $_[2]) };
$match_subs[HASH  ][REGEXP] = sub {
   for my $v (keys %{$_[0]}) {
      return 1 if $v =~ $_[1];
   }
   return;
};
$match_subs[HASH  ][SCALAR] = sub { _smart_match($_[0], ${$_[1]}, $_[2]) };
$match_subs[HASH  ][STRING] = sub { $_[0]->{$_[1]} };
$match_subs[HASH  ][UNDEF ] = undef;

$match_subs[NUMBER][NUMBER] = sub { $_[0] == $_[1] };
$match_subs[NUMBER][OBJECT] = undef;
$match_subs[NUMBER][REF   ] = sub { _smart_match($_[0], ${$_[1]}, $_[2]) };
$match_subs[NUMBER][REGEXP] = sub { $_[0] =~ $_[1] };
$match_subs[NUMBER][SCALAR] = sub { _smart_match($_[0], ${$_[1]}, $_[2]) };
$match_subs[NUMBER][STRING] = sub { no warnings 'numeric'; $_[0] == $_[1] };
$match_subs[NUMBER][UNDEF ] = sub { return };

$match_subs[OBJECT][OBJECT] = sub { $_[0] == $_[1] };
$match_subs[OBJECT][REF   ] = sub { _smart_match($_[0], ${$_[1]}, $_[2]) };
$match_subs[OBJECT][REGEXP] = undef;
$match_subs[OBJECT][SCALAR] = sub { _smart_match($_[0], ${$_[1]}, $_[2]) };
$match_subs[OBJECT][STRING] = sub {
   my $m = $_[1];
   $_[0]->can($m) && $_[0]->$m
};
$match_subs[OBJECT][UNDEF ] = sub { return };

$match_subs[REF   ][REF   ] = sub { _smart_match(${$_[0]}, ${$_[1]}, $_[2]) };
$match_subs[REF   ][REGEXP] = sub { _smart_match(${$_[0]}, $_[1], $_[2]) };
$match_subs[REF   ][SCALAR] = sub { _smart_match(${$_[0]}, $_[1], $_[2]) };
$match_subs[REF   ][STRING] = sub { _smart_match(${$_[0]}, $_[1], $_[2]) };
$match_subs[REF   ][UNDEF ] = sub { _smart_match(${$_[0]}, $_[1], $_[2]) };

$match_subs[REGEXP][REGEXP] = sub { $_[0] eq $_[1] };
$match_subs[REGEXP][SCALAR] = sub { _smart_match($_[0], ${$_[1]}, $_[2]) };
$match_subs[REGEXP][STRING] = sub { $_[1] =~ $_[0] };
$match_subs[REGEXP][UNDEF ] = sub { return };

$match_subs[SCALAR][SCALAR] = sub { _smart_match(${$_[0]}, ${$_[1]}, $_[2]) };
$match_subs[SCALAR][STRING] = sub { _smart_match(${$_[0]}, $_[1], $_[2]) };
$match_subs[SCALAR][UNDEF ] = sub { _smart_match(${$_[0]}, $_[1], $_[2]) };

$match_subs[STRING][STRING] = sub { $_[0] eq $_[1] };
$match_subs[STRING][UNDEF ] = sub { return };

$match_subs[UNDEF ][UNDEF ] = sub { return 1 };

## sole interface subroutine

sub smart_match {
   _smart_match(@_[0,1], {});
}

## private (by convention) internal subroutine

sub _smart_match {
   my ($val1, $val2, $seen) = @_;

   ## pre-emptive checks and recursion check
   my $addr1 = refaddr($val1);
   my $addr2 = refaddr($val2);

   if (defined $addr1 && defined $addr2) {

      ## return true if two references are equal
      return 1 if $addr1 == $addr2;

      ## return false if we repeat a comparison
      if ($addr1 > $addr2) {
         return if $seen->{$addr1}{$addr2}++;
      }
      else {
         return if $seen->{$addr2}{$addr1}++;
      }

   }

   ## determine the input types

   my $val1_type = _identify_type($val1);
   my $val2_type = _identify_type($val2);

   ## ensure that we can identify the input types

   confess "unrecognized type for val1: $val1"
      unless defined $val1_type;

   confess "unrecognized type for val2: $val2"
      unless defined $val2_type;

   ## re-order arguments for dynamically assigned match routines

   if ($val1_type > $val2_type) {
      ($val1, $val2)           = ($val2, $val1);
      ($val1_type, $val2_type) = ($val2_type, $val1_type);
   }

   ## ensure that we have a means of testing them

   confess "smart_match($type_names[$val1_type], $type_names[$val2_type]): "
         . "comparison not defined"
      unless defined $match_subs[$val1_type][$val2_type];

   ## test the arguments

   return $match_subs[$val1_type][$val2_type]->($val1, $val2, $seen);

}

## private (by convention) type identification subroutine

sub _identify_type {

   my $ref = ref $_[0];

   return ! defined $_[0]          ? UNDEF  :
          $ref eq 'ARRAY'          ? ARRAY  :
          $ref eq 'CODE'           ? CODE   :
          $ref eq 'HASH'           ? HASH   :
          $ref eq 'Regexp'         ? REGEXP :
          $ref eq 'SCALAR'         ? SCALAR :
          $ref eq 'REF'            ? REF    :
          $ref eq 'GLOB'           ? ()     :
          $ref eq 'LVALUE'         ? ()     :
          $ref                     ? OBJECT :
          looks_like_number($_[0]) ? NUMBER :
                                     STRING ;

}

sub given($&) {
  local $_ = $_[0];
  eval{ $_[1]->() };
  return @{$@}
}

sub when($&) {
  die([$_[1]->()]) if smart_match($_, $_[0]);
}

sub default(&) {
  die([$_[0]->()]);
}

1;
__END__
=head1 NAME

Match::Smart - best-guess matching of two scalars

=head1 SYNOPSIS

   use Match::Smart qw/ smart_match /;

   if (smart_match( $user, qr/^dan/ )) {
      print "You might be a dan\n";
   }

   if (smart_match( $amount, sub { $_[0] < 10} )) {
      print "$amount is less than 10\n";
   }


   use Match::Smart qw/ :all /;

   given $fruit => sub {
      when [qw/Honeycrisp Jonagold Braeburn/] => sub{ print "apple\n" };
      when [qw/Concord Red_Flame/] => sub{ print "grape\n" };
      default { print "Unknown fruit: $_\n" };
   }

=head1 DESCRIPTION

C<Match::Smart> provides a easy means of testing whether two variables match
based upon a set of rules derived from the syntax of Perl 5.10 & Apocalypse 4.

It also provides an analog for Perl 5.10's version of a switch statement.

=head1 EXPORT

Nothing is exported by default.

The C<smart_match()> subroutine can be exported if desired.

The I<:all> tag will provide the necessary routines for switching.

=head1 FUNCTIONS

=over 4

=item smart_match($val1, $val2)

Attempts to do the right thing in I<matching> the two given values. Returns
true if the two values I<match>, false otherwise.

If both values are references, referring to the same thing, they are assumed to
match.

The table below describes how the comparisons are performed. Those described
using C<grep> only do so for conciseness. The implementation uses C<for> loops
to allow short-circuiting as soon as a match is determined.

The order in which the values are passed to C<smart_match()> only affects the
return value when comparing two CODE references. Therefore, the table below
only shows half of the necessary comparisons (those missing can be inferred).

Those noted as '-' are not currently defined and will result in fatal run-time
exceptions.


   $val1    $val2    true if ...
   =====    =====    ===========

   ARRAY    ARRAY    smart_match($val1->[$_], $val2->[$_]) for 0 .. $#$val1
                            && $#$val1 == $#$val2
   ARRAY    CODE     !grep { !$val2->($_) } @{$val1}
   ARRAY    HASH     grep { exists $val2->{$_} } @{$val1}
   ARRAY    NUMBER   smart_match($_, $val2) for @$val1
   ARRAY    OBJECT   grep { smart_match($_, $val2)    } @{$val1}
   ARRAY    REF      grep { smart_match($_, ${$val2}) } @{$val1}
   ARRAY    REGEXP   grep { smart_match($_, $val2)    } @{$val1}
   ARRAY    SCALAR   grep { smart_match($_, ${$val2}) } @{$val1}
   ARRAY    STRING   grep { smart_match($_, $val2)    } @{$val1}
   ARRAY    UNDEF    grep { smart_match($_, $val2)    } @{$val1}

   CODE     CODE     $val2->(&{$val1})
   CODE     HASH     !grep { !$val1->($_) } keys %{$val2}
   CODE     NUMBER   $val1->($val2)
   CODE     OBJECT   $val1->($val2)
   CODE     REF      smart_match($val1, ${$val2})
   CODE     REGEXP   $val1->($val2)
   CODE     SCALAR   smart_match($val1, ${$val2})
   CODE     STRING   $val1->($val2)
   CODE     UNDEF    $val1->($val2)

   HASH     HASH     smart_match(keys %{$val1}, keys %{$val2})
   HASH     NUMBER   $val1->{$val2}
   HASH     OBJECT   -
   HASH     REF      smart_match($val1, ${$val2})
   HASH     REGEXP   grep { $_ =~ $val2 } keys %{$val1}
   HASH     SCALAR   smart_match($val1, ${$val2})
   HASH     STRING   $val1->{$val2}
   HASH     UNDEF    -

   NUMBER   NUMBER   $val1 == $val2
   NUMBER   OBJECT   -
   NUMBER   REF      smart_match($val1, ${$val2})
   NUMBER   REGEXP   $val1 =~ $val2
   NUMBER   SCALAR   smart_match($val1, ${$val2})
   NUMBER   STRING   $val1 == $val2
   NUMBER   UNDEF    ** ALWAYS FALSE **

   OBJECT   OBJECT   $val1 == $val2
   OBJECT   REF      smart_match($val1, ${$val2})
   OBJECT   REGEXP   -
   OBJECT   SCALAR   smart_match($val1, ${$val2})
   OBJECT   STRING   $val1->can($val2) && $val1->$val2
   OBJECT   UNDEF    ** ALWAYS FALSE **

   REF      REF      smart_match(${$val1}, ${$val2})
   REF      REGEXP   smart_match(${$val1}, $val2)
   REF      SCALAR   smart_match(${$val1}, ${$val2})
   REF      STRING   smart_match(${$val1}, $val2)
   REF      UNDEF    smart_match(${$val1}, $val2)

   REGEXP   REGEXP   $val1 eq $val2
   REGEXP   SCALAR   smart_match($val1, ${$val2})
   REGEXP   STRING   $val2 =~ $val1
   REGEXP   UNDEF    ** ALWAYS FALSE **

   SCALAR   SCALAR   smart_match(${$val1}, ${$val2})
   SCALAR   STRING   smart_match(${$val1}, $val2)
   SCALAR   UNDEF    smart_match(${$val1}, $val2)

   STRING   STRING   $val1 eq $val2
   STRING   UNDEF    ** ALWAYS FALSE **

   UNDEF    UNDEF    ** ALWAYS TRUE **

=back

=head1 TO DO

=over 4

=item - test against perl 5.10.1 t/op/smartmatch.t

=item - handle GLOB and LVALUE ref types

=item - provide a means of registering comparisons for specific Object types
        (call C<Class-E<gt>smart_match()> method to get class to fill in requirements)

=item - allow the comparison methods to be overridden

=back

=head1 SEE ALSO

Apocalypse 4: http://www.perl.com/pub/a/2002/01/15/apo4.html?page=2

Perl 5.10 syntax: http://perldoc.perl.org/perlsyn.html#Smart-matching-in-detail

=head1 AUTHOR

Daniel B. Boorstein, E<lt>danboo@cpan.orgE<gt>

With contributions from Jerrad Pierce.

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Daniel B. Boorstein

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
