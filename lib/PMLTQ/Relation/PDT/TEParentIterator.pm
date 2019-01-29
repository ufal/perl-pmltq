package PMLTQ::Relation::PDT::TEParentIterator;

# ABSTRACT: Effective parent relation iterator on t-nodes for PDT like treebanks

use strict;
use warnings;
use base qw(PMLTQ::Relation::SimpleListIterator);
use PMLTQ::Relation {
  name              => 'eparent',
  table_name        => 'tdata__#eparents',
  schema            => 'tdata',
  tree_root         => 't-root',
  reversed_relation => 'implementation:echild',
  start_node_type   => 't-node',
  target_node_type  => 't-node',
  iterator_class    => __PACKAGE__,
  iterator_weight   => 2,
  test_code         => q( grep($_ == $end, PMLTQ::Relation::PDT::TGetEParents($start)) ? 1 : 0 ),
};
use PMLTQ::Relation::PDT;

BEGIN {
  {
    local $@; # protect existing $@
    eval {
      require PMLTQ::PML2BASE::Relation::PDT::TEParentIterator;
      PMLTQ::PML2BASE::Relation::PDT::TEParentIterator->import();
    };
    print STDERR "PMLTQ::PML2BASE::Relation::PDT::TEParentIterator is not installed\n" if $@;
  }
}

sub get_node_list {
  my ($self, $node) = @_;
  my $type   = $node->type->get_base_type_name;
  my $fsfile = $self->start_file;
  return [ map [ $_, $fsfile ], PMLTQ::Relation::PDT::TGetEParents($node) ];
}

sub dump_relation {
  my ($tree,$hash,$fh)=@_;

  PMLTQ::PML2BASE::Relation::PDT::TEParentIterator::dump_relation($tree,$hash,$fh);
}

1;
