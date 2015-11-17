package PMLTQ::Relation::Treex::AEParentCIterator;

# ABSTRACT: Different implementation of effective parent relation iterator on a-nodes for Treex treebanks

=head1 DESCRIPTION

Classic effective parent implementation is skipping nodes with afuns that match /Aux[CP]/. This one doesn't.

=cut

use strict;
use warnings;
use base qw(PMLTQ::Relation::SimpleListIterator);
use PMLTQ::Relation {
  name              => 'eparentC',
  schema            => 'treex_document',
  reversed_relation => 'implementation:echildC',
  start_node_type   => 'a-node',
  target_node_type  => 'a-node',
  iterator_class    => __PACKAGE__,
  test_code         => q(grep($_ == $end, PMLTQ::Relation::Treex::AGetEParentsC($start)) ? 1 : 0),
};


sub get_node_list {
  my ( $self, $node ) = @_;
  my $fsfile = $self->start_file;
  return [ map [ $_, $fsfile ], PMLTQ::Relation::Treex::AGetEParentsC($node) ];
}

1;
