package PMLTQ::Relation::Iterator;

# ABSTRACT: Base Iterator class

use 5.006;
use strict;
use warnings;

use constant CONDITIONS=>0;
use Carp;

sub new {
  my ($class,$conditions)=@_;
  croak "usage: $class->new(sub{...})" unless ref($conditions) eq 'CODE';
  return bless [$conditions],$class;
}

sub clone {
  my ($self)=@_;
  return bless [$self->[CONDITIONS]], ref($self);
}

sub conditions { return $_[0]->[CONDITIONS]; }

sub set_conditions { $_[0]->[CONDITIONS]=$_[1]; }

sub start {}

sub next {}

sub node {}

sub reset {}

1; # End of PMLTQ::Relation::Iterator
