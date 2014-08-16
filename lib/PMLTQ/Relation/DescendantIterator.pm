package PMLTQ::Relation::DescendantIterator;

use 5.006;
use strict;
use warnings;

use base qw(PMLTQ::Relation::Iterator);
use constant CONDITIONS=>0;
use constant NODE=>1;
use constant TOP=>2;
use constant FILE=>3;

sub start  {
  my ($self,$parent,$fsfile)=@_;
  if ($fsfile) {
    $self->[FILE]=$fsfile;
  } else {
    $fsfile=$self->[FILE];
  }
  my $n= $parent->firstson;
  $self->[NODE]=$n;
  $self->[TOP]=$parent;
  return ($n && $self->[CONDITIONS]->($n,$fsfile)) ? $n : ($n && $self->next);
}
sub next {
  my ($self)=@_;
  my $conditions=$self->[CONDITIONS];
  my $top = $self->[TOP];
  my $n=$self->[NODE]->following($top);
  my $fsfile=$self->[FILE];
  $n=$n->following($top) while ($n and !$conditions->($n,$fsfile));
  return $self->[NODE]=$n;
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
  $self->[TOP]=undef;
  $self->[FILE]=undef;
}

1; # End of PMLTQ::Relation::DescendantIterator

__END__

=pod

=head1 NAME

PMLTQ::Relation::DescendantIterator

=cut
