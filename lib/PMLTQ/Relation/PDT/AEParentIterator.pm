package PMLTQ::Relation::PDT::AEParentIterator;

# ABSTRACT: Effective parent relation iterator on a-nodes for PDT like treebanks

use strict;
use warnings;
use base qw(PMLTQ::Relation::SimpleListIterator);
use PMLTQ::Relation {
  name              => 'eparent',
  table_name        => 'adata__#eparents',
  schema            => 'adata',
  tree_root         => 'a-root',
  reversed_relation => 'implementation:echild',
  start_node_type   => 'a-node',
  target_node_type  => 'a-node',
  iterator_class    => __PACKAGE__,
  iterator_weight   => 2,
  test_code         => q( grep($_ == $end, PMLTQ::Relation::PDT::AGetEParents($start,\&PMLTQ::Relation::PDT::ADiveAuxCP)) ? 1 : 0 ),
};
use PMLTQ::Relation::PDT;

BEGIN {
  {
    local $@; # protect existing $@
    eval {
      require PMLTQ::PML2BASE::Relation::PDT::AEParentIterator;
      PMLTQ::PML2BASE::Relation::PDT::AEParentIterator->import();
    };
    print STDERR "PMLTQ::PML2BASE::Relation::PDT::AEParentIterator is not installed\n" if $@;
  }
}

sub get_node_list {
  my ($self, $node) = @_;
  my $type   = $node->type->get_base_type_name;
  my $fsfile = $self->start_file;
  return [ map [ $_, $fsfile ], PMLTQ::Relation::PDT::AGetEParents($node, \&PMLTQ::Relation::PDT::ADiveAuxCP) ];
}

sub dump_relation {
  my ($tree,$hash,$fh)=@_;

  PMLTQ::PML2BASE::Relation::PDT::AEParentIterator::dump_relation($tree,$hash,$fh);
}


1;
