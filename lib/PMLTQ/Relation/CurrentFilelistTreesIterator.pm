package PMLTQ::Relation::CurrentFilelistTreesIterator;

use 5.006;
use strict;
use warnings;

use base qw(PMLTQ::Relation::Iterator);
use constant CONDITIONS=>0;
use constant NODE=>1;

our $PROGRESS; ### newly added
our $STOP; ### newly added

sub start  {
  my ($self)=@_;
  TredMacro::GotoFileNo(0);
  $TredMacro::this=$TredMacro::root;
  $self->[NODE]=$TredMacro::this;
  my $fsfile = $TredMacro::grp->{FSFile};
  return ($TredMacro::this && $self->[CONDITIONS]->($TredMacro::this,$fsfile)) ? $TredMacro::this : ($TredMacro::this && $self->next);
}
sub next {
  my ($self)=@_;
  my $conditions=$self->[CONDITIONS];
  my $n=$self->[NODE];
  my $fsfile = $TredMacro::grp->{FSFile};
  while ($n) {
    $n = $n->following
      || (($PROGRESS ? $PROGRESS->() : 1) && $STOP && do { $n = undef; last })
      ||  (TredMacro::NextFile() && ($fsfile=$TredMacro::grp->{FSFile}) && $TredMacro::this);
    last if $conditions->($n,$fsfile);
  }
  return $self->[NODE]=$n;
}
sub node {
  return $_[0]->[NODE];
}
sub file {
  return $TredMacro::grp->{FSFile};
}
sub reset {
  my ($self)=@_;
  $self->[NODE]=undef;
}

1; # End of PMLTQ::Relation::CurrentFilelistTreesIterator

__END__

=pod

=head1 NAME

PMLTQ::Relation::CurrentFilelistTreesIterator

=cut
