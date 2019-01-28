package PMLTQ::Relation::PDT::AEParentIterator;
our $AUTHORITY = 'cpan:MATY';
$PMLTQ::Relation::PDT::AEParentIterator::VERSION = '3.0.0'; # TRIAL
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

__END__

=pod

=encoding UTF-8

=head1 NAME

PMLTQ::Relation::PDT::AEParentIterator - Effective parent relation iterator on a-nodes for PDT like treebanks

=head1 VERSION

version 3.0.0

=head1 AUTHORS

=over 4

=item *

Petr Pajas <pajas@ufal.mff.cuni.cz>

=item *

Jan Štěpánek <stepanek@ufal.mff.cuni.cz>

=item *

Michal Sedlák <sedlak@ufal.mff.cuni.cz>

=item *

Matyáš Kopp <matyas.kopp@gmail.com>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Institute of Formal and Applied Linguistics (http://ufal.mff.cuni.cz).

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
