package PMLTQ::Relation::PDT::TEChildIterator;
our $AUTHORITY = 'cpan:MATY';
$PMLTQ::Relation::PDT::TEChildIterator::VERSION = '1.2.1';
# ABSTRACT: Effective child relation iterator on t-nodes for PDT like treebanks

use strict;
use warnings;
use base qw(PMLTQ::Relation::SimpleListIterator);
use PMLTQ::Relation {
  name              => 'echild',
  schema            => 'tdata',
  reversed_relation => 'implementation:eparent',
  start_node_type   => 't-node',
  target_node_type  => 't-node',
  iterator_class    => __PACKAGE__,
  iterator_weight   => 5,
  test_code         => q( grep($_ == $start, PMLTQ::Relation::PDT::TGetEParents($end)) ? 1 : 0 ),
};


sub get_node_list {
  my ($self, $node) = @_;
  my $type   = $node->type->get_base_type_name;
  my $fsfile = $self->start_file;
  return [ map [ $_, $fsfile ], PMLTQ::Relation::PDT::TGetEChildren($node) ];
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

PMLTQ::Relation::PDT::TEChildIterator - Effective child relation iterator on t-nodes for PDT like treebanks

=head1 VERSION

version 1.2.1

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
