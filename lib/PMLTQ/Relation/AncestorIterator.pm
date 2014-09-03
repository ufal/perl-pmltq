package PMLTQ::Relation::AncestorIterator;

# ABSTRACT: Iterates over ancestor nodes

use 5.006;
use strict;
use warnings;

use base qw(PMLTQ::Relation::Iterator);
use constant CONDITIONS=>0;
use constant NODE=>1;
use constant FILE=>2;

sub start  {
  my ($self,$node,$fsfile)=@_;
  $self->[FILE]=$fsfile;
  my $n = $node->parent;
  $self->[NODE]=$n;
  return ($n && $self->[CONDITIONS]->($n,$fsfile)) ? $n : ($n && $self->next);
}
sub next {
  my ($self)=@_;
  my $conditions=$self->[CONDITIONS];
  my $n=$self->[NODE]->parent;
  my $fsfile = $self->[FILE];
  $n=$n->parent while ($n and !$conditions->($n,$fsfile));
  return $_[0]->[NODE]=$n;
}
sub node {
  return $_[0]->[NODE];
}
sub file {
  return $_[0]->[FILE];
}
sub reset {
  my ($self)=@_;
  $self->[NODE]=undef;
  $self->[FILE]=undef;
}

1; # End of PMLTQ::Relation::AncestorIterator
