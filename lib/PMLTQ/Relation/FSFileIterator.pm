package PMLTQ::Relation::FSFileIterator;

# ABSTRACT: Iterates nodes of given fsfile

use 5.006;
use strict;
use warnings;

use Carp;
use base qw(PMLTQ::Relation::Iterator);
use constant CONDITIONS=>0;
use constant FILE=>1;
use constant TREE_NO=>2;
use constant NODE=>3;

our $PROGRESS; ### newly added
our $STOP; ### newly added

sub new {
  my ($class,$conditions,$fsfile)=@_;
  croak "usage: $class->new(sub{...})" unless ref($conditions) eq 'CODE';
  return bless [$conditions,$fsfile],$class;
}
sub clone {
  my ($self)=@_;
  return bless [$self->[CONDITIONS],$self->[FILE]], ref($self);
}
sub start  {
  my ($self,undef,$fsfile)=@_;
  $self->[TREE_NO]=0;
  if ($fsfile) {
    $self->[FILE]=$fsfile;
  } else {
    $fsfile=$self->[FILE];
  }
  my $n = $self->[NODE] = $self->[FILE]->tree(0);
  return ($n && $self->[CONDITIONS]->($n,$fsfile)) ? $n : ($n && $self->next);
}
sub next {
  my ($self)=@_;
  my $conditions=$self->[CONDITIONS];
  my $n=$self->[NODE];
  my $fsfile=$self->[FILE];
  while ($n) {
    $n = $n->following || (($PROGRESS ? $PROGRESS->() : 1) && $STOP && do { $n = undef; last }) || $fsfile->tree(++$self->[TREE_NO]);
    last if $conditions->($n,$fsfile);
  }
  return $self->[NODE]=$n;
}
sub node {
  return $_[0]->[NODE];
}
sub file {
  return $_[0]->[FILE];
}
sub set_file {
  return $_[0]->[FILE]=$_[1];
}
sub reset {
  my ($self)=@_;
  $self->[NODE]=undef;
}

1; # End of PMLTQ::Relation::FSFileIterator
