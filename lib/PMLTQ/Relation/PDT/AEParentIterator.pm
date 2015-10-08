package PMLTQ::Relation::PDT::AEParentIterator;

use strict;
use warnings;
use base qw(PMLTQ::Relation::SimpleListIterator);
use PMLTQ::Relation {
  name              => 'eparent',
  reversed_relation => 'implementation:echild',
  start_node_type   => 'a-node',
  target_node_type  => 'a-node',
  iterator_class    => __PACKAGE__,
  test_code         => q( grep($_ == $end, PML_A::GetEParents($start,\&PML_A::DiveAuxCP)) ? 1 : 0 ),
};


sub get_node_list {
  my ($self, $node) = @_;
  my $type   = $node->type->get_base_type_name;
  my $fsfile = $self->start_file;
  return [ map [ $_, $fsfile ], PML_A::GetEParents($node, \&PML_A::DiveAuxCP) ];
}

1;