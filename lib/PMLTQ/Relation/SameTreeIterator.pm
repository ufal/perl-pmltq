package PMLTQ::Relation::SameTreeIterator;

# ABSTRACT: Evaluates condition on nodes of current tree

use 5.006;
use strict;
use warnings;

use Carp;
use base qw(PMLTQ::Relation::TreeIterator);

sub new  {
  my ($class,$conditions)=@_;
  croak "usage: $class->new(sub{...})" unless ref($conditions) eq 'CODE';
  return bless [$conditions],$class;
}
sub start  {
  my ($self,$root,$fsfile)=@_;
  $root=$root->root if $root;
  $self->[PMLTQ::Relation::TreeIterator::NODE] = $self->[PMLTQ::Relation::TreeIterator::TREE] = $root;
  $self->[PMLTQ::Relation::TreeIterator::FILE]=$fsfile;
  return ($root && $self->[PMLTQ::Relation::TreeIterator::CONDITIONS]->($root,$fsfile)) ? $root : ($root && $self->next);
}

1; # End of PMLTQ::Relation::SameTreeIterator
