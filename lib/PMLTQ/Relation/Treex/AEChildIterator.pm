package PMLTQ::Relation::Treex::AEChildIterator;

use strict;
use warnings;
use base qw(PMLTQ::Relation::SimpleListIterator);
use PMLTQ::Relation {
  name              => 'echild',
  reversed_relation => 'implementation:eparent',
  start_node_type   => 'a-node',
  target_node_type  => 'a-node',
  iterator_class    => __PACKAGE__,
  iterator_weight   => 5,
  test_code         => q( grep($_ == $start, PMLTQ::Relation::Treex::AGetEParents($end)) ? 1 : 0 ),
};


sub get_node_list {
  my ($self, $node) = @_;
  my $type   = $node->type->get_base_type_name;
  my $fsfile = $self->start_file;
  return [ map [ $_, $fsfile ], PMLTQ::Relation::Treex::AGetEChildren($node) ];
}

1;