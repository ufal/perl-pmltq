package PMLTQ::Relation::Treex::AEParentIterator;

# ABSTRACT: Effective parent relation iterator on a-nodes for Treex treebanks

use strict;
use warnings;
use base qw(PMLTQ::Relation::SimpleListIterator);
use PMLTQ::Relation {
  name              => 'eparent',
  table_name        => 'adata__#eparents',
  schema            => 'treex_document',
  reversed_relation => 'implementation:echild',
  start_node_type   => 'a-node',
  target_node_type  => 'a-node',
  iterator_class    => __PACKAGE__,
  test_code         => q(grep($_ == $end, PMLTQ::Relation::Treex::AGetEParents($start)) ? 1 : 0),
};
use PMLTQ::Relation::Treex;

BEGIN {
  {
    local $@; # protect existing $@
    eval {
      require PMLTQ::PML2BASE::Relation::Treex::AEParentIterator;
      PMLTQ::PML2BASE::Relation::Treex::AEParentIterator->import();
    };
    print STDERR "PMLTQ::PML2BASE::Relation::Treex::TEParentIterator is not installed\n" if $@;
    print STDERR "PMLTQ::PML2BASE::Relation::Treex::AEParentIterator is not installed\n" if $@;
  }
}

sub get_node_list {
  my ( $self, $node ) = @_;
  my $fsfile = $self->start_file;
  return [ map [ $_, $fsfile ], PMLTQ::Relation::Treex::AGetEParents($node) ];
}

sub dump_relation {
  my ($tree, $hash, $fh ) = @_;
  PMLTQ::PML2BASE::Relation::Treex::AEParentIterator::dump_relation($tree, $hash, $fh );
}

1;
