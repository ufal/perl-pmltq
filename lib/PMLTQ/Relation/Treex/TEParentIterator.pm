package PMLTQ::Relation::Treex::TEParentIterator;
our $AUTHORITY = 'cpan:MATY';
$PMLTQ::Relation::Treex::TEParentIterator::VERSION = '3.0.1';
# ABSTRACT: Effective parent relation iterator on t-nodes for Treex treebanks

use strict;
use warnings;
use base qw(PMLTQ::Relation::SimpleListIterator);
use PMLTQ::Relation {
  name              => 'eparent',
  table_name        => 'tdata__#eparents',
  schema            => 'treex_document',
  reversed_relation => 'implementation:echild',
  start_node_type   => 't-node',
  target_node_type  => 't-node',
  iterator_class    => __PACKAGE__,
  iterator_weight   => 2,
  test_code         => q( grep($_ == $end, PMLTQ::Relation::Treex::TGetEParents($start)) ? 1 : 0 ),
};

BEGIN {
  {
    local $@; # protect existing $@
    eval {
      require PMLTQ::PML2BASE::Relation::Treex::TEParentIterator;
      PMLTQ::PML2BASE::Relation::Treex::TEParentIterator->import();
    };
    print STDERR "PMLTQ::PML2BASE::Relation::Treex::TEParentIterator is not installed\n" if $@;
  }
}

sub get_node_list {
  my ( $self, $node ) = @_;
  my $type   = $node->type->get_base_type_name;
  my $fsfile = $self->start_file;
  return [ map [ $_, $fsfile ], PMLTQ::Relation::Treex::TGetEParents($node) ];
}

sub dump_relation {
  my ($tree, $hash, $fh ) = @_;
  PMLTQ::PML2BASE::Relation::Treex::TEParentIterator::dump_relation($tree, $hash, $fh );
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

PMLTQ::Relation::Treex::TEParentIterator - Effective parent relation iterator on t-nodes for Treex treebanks

=head1 VERSION

version 3.0.1

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
