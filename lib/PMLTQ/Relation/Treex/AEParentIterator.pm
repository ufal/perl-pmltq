package PMLTQ::Relation::Treex::AEParentIterator;

use strict;
use warnings;
use base qw(PMLTQ::Relation::SimpleListIterator);
use PMLTQ::Relation {
  name              => 'eparent',
  reversed_relation => 'implementation:echild',
  start_node_type   => 'a-node',
  target_node_type  => 'a-node',
  iterator_class    => __PACKAGE__,
  test_code         => q(grep($_ == $end, PMLTQ::Relation::Treex::AGetEParents($start)) ? 1 : 0),
};


sub get_node_list {
  my ($self, $node) = @_;
  my $fsfile = $self->start_file;
  return [ map [ $_, $fsfile ], PMLTQ::Relation::Treex::AGetEParents($node) ];
}

1;