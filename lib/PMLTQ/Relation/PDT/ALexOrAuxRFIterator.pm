package PMLTQ::Relation::PDT::ALexOrAuxRFIterator;

use strict;
use base qw(PMLTQ::Relation::SimpleListIterator);
use PMLTQ::Relation {
  name             => 'a/lex.rf|a/aux.rf',
  start_node_type  => 't-node',
  target_node_type => 'a-node',
  iterator_class   => __PACKAGE__,
  iterator_weight  => 2,
  test_code        => q(grep($_ eq $end->{id}, PML_T::GetANodeIDs($start)) ? 1 : 0),
};


sub get_node_list {
  my ($self, $node) = @_;
  my $fsfile = $self->start_file;
  my $a_file = PML_T::AFile($fsfile);
  return [ $a_file ? map [ $_, $a_file ], PML_T::GetANodes($node, $fsfile) : () ];
}

1;