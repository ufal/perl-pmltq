package PMLTQ::Relation::PDT::ALexOrAuxRFIterator;

use strict;
use warnings;
use base qw(PMLTQ::Relation::SimpleListIterator);
use PMLTQ::Relation {
  name             => 'a/lex.rf|a/aux.rf',
  start_node_type  => 't-node',
  target_node_type => 'a-node',
  iterator_class   => __PACKAGE__,
  iterator_weight  => 2,
  test_code        => q(grep($_ eq $end->{id}, PMLTQ::Relation::PDT::TGetANodeIDs($start)) ? 1 : 0),
};


sub get_node_list {
  my ($self, $node) = @_;
  my $fsfile = $self->start_file;
  my $a_file = TAFile($fsfile);
  return [ $a_file ? map [ $_, $a_file ], PMLTQ::Relation::PDT::TGetANodes($node, $fsfile) : () ];
}

1;