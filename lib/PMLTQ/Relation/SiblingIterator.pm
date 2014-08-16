package PMLTQ::Relation::SiblingIterator;

use 5.006;
use strict;
use warnings;

use base qw(PMLTQ::Relation::Iterator);
use constant CONDITIONS=>0;
use constant NODE=>1;
use constant FILE=>2;
use constant START=>3;

sub start  {
  my ($self,$start_node,$fsfile)=@_;
  $self->[FILE]=$fsfile;
  $self->[START]=$start_node;
  my $n = $start_node->parent;
  $n=$n && $n->firstson;
  $n=$n->rbrother if $n && $n==$start_node;
  $self->[NODE]=$n;
  return ($n && $self->[CONDITIONS]->($n,$fsfile)) ? $n : ($n && $self->next);
}
sub next {
  my ($self)=@_;
  my $conditions=$self->[CONDITIONS];
  my $n=$self->[NODE]->rbrother;
  my $start_node = $self->[START];
  my $fsfile = $self->[FILE];
  $n=$n->rbrother while ($n and !($n!=$start_node and $conditions->($n,$fsfile)));
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
  $self->[START]=undef;
}

1; # End of PMLTQ::Relation::SiblingIterator

__END__

=pod

=head1 NAME

PMLTQ::Relation::SiblingIterator

=cut
