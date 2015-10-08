package PMLTQ::Relation::PDT::TEChildIterator;

use strict;
use warnings;
use base qw(PMLTQ::Relation::SimpleListIterator);
use PMLTQ::Relation {
  name              => 'echild',
  reversed_relation => 'implementation:eparent',
  start_node_type   => 't-node',
  target_node_type  => 't-node',
  iterator_class    => __PACKAGE__,
  iterator_weight   => 5,
  test_code         => q( grep($_ == $start, PML_T::GetEParents($end)) ? 1 : 0 ),
};


sub get_node_list {
  my ($self, $node) = @_;
  my $type   = $node->type->get_base_type_name;
  my $fsfile = $self->start_file;
  return [ map [ $_, $fsfile ], PML_T::GetEChildren($node) ];
}

1;