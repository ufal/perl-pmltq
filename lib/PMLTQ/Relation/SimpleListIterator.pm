package PMLTQ::Relation::SimpleListIterator;

use 5.006;
use strict;
use warnings;

use base qw(PMLTQ::Relation::Iterator);
use constant CONDITIONS=>0;
use constant NODES=>1;
use constant FILE=>2;
use constant FIRST_FREE=>3; # number of the first constant free for user

sub start  {
  my ($self,$node,$fsfile)=@_;
  $self->[FILE]=$fsfile;
  my $nodes = $self->[NODES] = $self->get_node_list($node);
  my $n = $nodes->[0];
  return ($n && $self->[CONDITIONS]->(@$n)) ? $n->[0] : ($n->[0] && $self->next);
}
sub next {
  my ($self)=@_;
  my $nodes = $self->[NODES];
  my $conditions=$self->[CONDITIONS];
  shift @{$nodes};
  my $n;
  while (($n = $nodes->[0]) and !$conditions->(@$n)) {
    shift @{$nodes};
  }
  return $nodes->[0][0];
}
sub node {
  my ($self)=@_;
  my $n = $self->[NODES][0];
  return $n && $n->[0];
}
sub file {
  my ($self)=@_;
  my $n = $self->[NODES][0];
  return $n && $n->[1];
}
sub reset {
  my ($self)=@_;
  $self->[NODES]=undef;
  $self->[FILE]=undef;
}
sub get_node_list {
  return [];
}
sub start_file {
  my ($self)=@_;
  return $self->[FILE];
}

1; # End of PMLTQ::Relation::SimpleListIterator
