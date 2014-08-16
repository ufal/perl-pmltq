package PMLTQ::Relation::TreexFilelistIterator;

use 5.006;
use strict;
use warnings;
use base qw(PMLTQ::Relation::TreexFileIterator);

our $PROGRESS; ### newly added
our $STOP; ### newly added

sub next {
  my ($self)=@_;
  my $conditions=$self->[PMLTQ::Relation::CurrentFileIterator::CONDITIONS];
  my $n=$self->[PMLTQ::Relation::CurrentFileIterator::NODE];
  my $f=$self->[PMLTQ::Relation::CurrentFileIterator::FILE];
  while ($n) {
    $n = $n->following
      || (($PROGRESS ? $PROGRESS->() : 1) && $STOP && do { $n = undef; last })
      || $self->tree(++$self->[PMLTQ::Relation::CurrentFileIterator::TREE_NO])
      || $self->_next_file();
    unless ($n) {
      while (TredMacro::NextFile()) {
        $self->[PMLTQ::Relation::CurrentFileIterator::TREE_NO]=0;
        $f = $TredMacro::grp->{FSFile};
        $self->[PMLTQ::Relation::CurrentFileIterator::FILE_QUEUE] = [$f];
        $n = $self->_next_file();
        last if $n;
      }
    }
    last if $conditions->($n,$f);
  }
  return $self->[PMLTQ::Relation::CurrentFileIterator::NODE]=$n;
}

1; # End of PMLTQ::Relation::TreexFilelistIterator
