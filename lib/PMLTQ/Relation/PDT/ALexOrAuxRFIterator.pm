package PMLTQ::Relation::PDT::ALexOrAuxRFIterator;

# ABSTRACT: a/lex.rf or a/aux.rf relation iterator for PDT like treebanks

use strict;
use warnings;
use base qw(PMLTQ::Relation::SimpleListIterator);
use PMLTQ::Relation {
  name             => 'a/lex.rf|a/aux.rf',
  table_name       => 'tdata__#a_rf',
  schema           => 'tdata',
  tree_root        => 't-root',
  start_node_type  => 't-node',
  target_node_type => 'a-node',
  iterator_class   => __PACKAGE__,
  iterator_weight  => 2,
  test_code        => q(grep($_ eq $end->{id}, PMLTQ::Relation::PDT::TGetANodeIDs($start)) ? 1 : 0),
};

BEGIN {
  {
    local $@; # protect existing $@
    eval {
      require PMLTQ::PML2BASE::Relation::PDT::ALexOrAuxRFIterator;
      PMLTQ::PML2BASE::Relation::PDT::ALexOrAuxRFIterator->import();
    };
    print STDERR "PMLTQ::PML2BASE::PDT::ALexOrAuxRFIterator is not installed\n" if $@;
  }
}


sub get_node_list {
  my ($self, $node) = @_;
  my $fsfile = $self->start_file;
  my $a_file = TAFile($fsfile); # TODO: TAFile is not defined !!
  return [ $a_file ? map [ $_, $a_file ], PMLTQ::Relation::PDT::TGetANodes($node, $fsfile) : () ];
}

sub init_sql {
  my ($table_name, $schema, $desc, $fh) = @_;

  PMLTQ::PML2BASE::Relation::PDT::ALexOrAuxRFIterator::init_sql($table_name, $schema, $desc, $fh);
}

1;
