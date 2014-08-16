package PMLTQ::Relation::ParentIterator;

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
  return $self->[NODE] = ($n && $self->[CONDITIONS]->($n,$fsfile)) ? $n : undef;
}
sub next {
  return $_[0]->[NODE]=undef;
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

1; # End of PMLTQ::Relation::ParentIterator
