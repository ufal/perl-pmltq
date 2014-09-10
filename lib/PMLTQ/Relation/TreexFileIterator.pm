package PMLTQ::Relation::TreexFileIterator;
BEGIN {
  $PMLTQ::Relation::TreexFileIterator::AUTHORITY = 'cpan:MICHALS';
}
$PMLTQ::Relation::TreexFileIterator::VERSION = '0.8.1';
# ABSTRACT: Same as L<PMLTQ::Relation::FileIterator> but for Treex files

use 5.006;
use strict;
use warnings;

use base qw(PMLTQ::Relation::CurrentFileIterator);
use constant TREES=>PMLTQ::Relation::CurrentFileIterator::FIRST_FREE;
use constant TREEX_DOC=>PMLTQ::Relation::CurrentFileIterator::FIRST_FREE+1;

our $PROGRESS; ### newly added
our $STOP; ### newly added

sub new {
  my ($class,$conditions,$schema_root_name)=@_;
  my $self = CurrentFileIterator->new($conditions, $schema_root_name);
  $self->[TREES] = [];
  return bless $self, $class; # rebless
}

sub tree {
  my ($self, $n)=@_;
  return $self->[TREES]->[$n];
}

sub _next_file {
  my ($self)=@_;
  my $f;
  my $schema_name = $self->[PMLTQ::Relation::CurrentFileIterator::SCHEMA_ROOT_NAME];
  while (@{$self->[PMLTQ::Relation::CurrentFileIterator::FILE_QUEUE]}) {
    $f = shift @{$self->[PMLTQ::Relation::CurrentFileIterator::FILE_QUEUE]};
    if ($f) {
      push @{$self->[PMLTQ::Relation::CurrentFileIterator::FILE_QUEUE]}, TredMacro::GetSecondaryFiles($f);
      if (!defined($schema_name) or $schema_name eq PML::SchemaName($f)) {
        $self->[PMLTQ::Relation::CurrentFileIterator::FILE]=$f;
        $self->[TREEX_DOC] = Treex::Core::Document->new({pmldoc => $f}) if $ENV{TREEX_EXTENSION};
        $self->[PMLTQ::Relation::CurrentFileIterator::TREE_NO]=0;
        $self->_extract_trees;
        my $n = $self->[PMLTQ::Relation::CurrentFileIterator::NODE] = $self->tree(0);
        return ($n && $self->[PMLTQ::Relation::CurrentFileIterator::CONDITIONS]->($n,$f)) ? $n : ($n && $self->next)
      }
    }
  }
  return;
}

# Don't use any treex specific methods, nodes might not be reblessed
sub _extract_trees {
  my ($self)=@_;
  my $file = $self->[PMLTQ::Relation::CurrentFileIterator::FILE];
  # lets assume it's treex file
  $self->[TREES] = [$file->trees];
  foreach my $bundle ($file->trees) {
    last unless defined $bundle->{zones};
    foreach my $zone ($bundle->{zones}->values) {
      push @{$self->[TREES]}, grep {defined}
        map {$zone->{trees}->{$_ . "_tree"};} qw(a t n p);
    }
  }
}

sub next {
  my ($self)=@_;
  my $conditions=$self->[PMLTQ::Relation::CurrentFileIterator::CONDITIONS];
  my $n=$self->[PMLTQ::Relation::CurrentFileIterator::NODE];
  my $f=$self->[PMLTQ::Relation::CurrentFileIterator::FILE];
  while ($n) {
    $n = $n->following ||
      (($PROGRESS ? $PROGRESS->() : 1) && $STOP && do { $n = undef; last }) ||
        $self->tree(++$self->[PMLTQ::Relation::CurrentFileIterator::TREE_NO]) || $self->_next_file();

    last if $conditions->($n,$f);
  }
  return $self->[PMLTQ::Relation::CurrentFileIterator::NODE]=$n;
}

1; # End of PMLTQ::Relation::TreexFileIterator

__END__

=pod

=encoding UTF-8

=head1 NAME

PMLTQ::Relation::TreexFileIterator - Same as L<PMLTQ::Relation::FileIterator> but for Treex files

=head1 VERSION

version 0.8.1

=head1 AUTHORS

=over 4

=item *

Petr Pajas <pajas@ufal.mff.cuni.cz>

=item *

Jan Štěpánek <stepanek@ufal.mff.cuni.cz>

=item *

Michal Sedlák <sedlak@ufal.mff.cuni.cz>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Institute of Formal and Applied Linguistics (http://ufal.mff.cuni.cz).

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
