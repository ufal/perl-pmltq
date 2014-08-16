package PMLTQ::Relation::CurrentTreeIterator;

use 5.006;
use strict;
use warnings;

use base qw(PMLTQ::Relation::Iterator);
use constant CONDITIONS=>0;
use constant NODE=>1;

sub start  {
  my ($self)=@_;
  $TredMacro::this=$TredMacro::root;
  $self->[NODE]=$TredMacro::this;
  return ($TredMacro::this && $self->[CONDITIONS]->($TredMacro::this,TredMacro::CurrentFile())) ? $TredMacro::this : ($TredMacro::this && $self->next);
}
sub next {
  my ($self)=@_;
  my $conditions=$self->[CONDITIONS];
  my $n=$self->[NODE];
  my $fsfile=TredMacro::CurrentFile();
  while ($n) {
    $n = $n->following;
    last if $conditions->($n,$fsfile);
  }
  return $self->[NODE]=$n;
}
sub file {
  return TredMacro::CurrentFile();
}
sub node {
  return $_[0]->[NODE];
}
sub reset {
  my ($self)=@_;
  $self->[NODE]=undef;
}

1; # End of PMLTQ::Relation::CurrentTreeIterator

__END__

=pod

=head1 NAME

PMLTQ::Relation::CurrentTreeIterator

=cut
