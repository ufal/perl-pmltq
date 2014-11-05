package PMLTQ::Relation::FSFileIterator;
our $AUTHORITY = 'cpan:MICHALS';
{
  $PMLTQ::Relation::FSFileIterator::VERSION = '0.8.3';
}

# ABSTRACT: Iterates nodes of given fsfile

use 5.006;
use strict;
use warnings;

use Carp;
use base qw(PMLTQ::Relation::Iterator);
use constant CONDITIONS=>0;
use constant FILE=>1;
use constant TREE_NO=>2;
use constant NODE=>3;

our $PROGRESS; ### newly added
our $STOP; ### newly added

sub new {
  my ($class,$conditions,$fsfile)=@_;
  croak "usage: $class->new(sub{...})" unless ref($conditions) eq 'CODE';
  return bless [$conditions,$fsfile],$class;
}
sub clone {
  my ($self)=@_;
  return bless [$self->[CONDITIONS],$self->[FILE]], ref($self);
}
sub start  {
  my ($self,undef,$fsfile)=@_;
  $self->[TREE_NO]=0;
  if ($fsfile) {
    $self->[FILE]=$fsfile;
  } else {
    $fsfile=$self->[FILE];
  }
  my $n = $self->[NODE] = $self->[FILE]->tree(0);
  return ($n && $self->[CONDITIONS]->($n,$fsfile)) ? $n : ($n && $self->next);
}
sub next {
  my ($self)=@_;
  my $conditions=$self->[CONDITIONS];
  my $n=$self->[NODE];
  my $fsfile=$self->[FILE];
  while ($n) {
    $n = $n->following || (($PROGRESS ? $PROGRESS->() : 1) && $STOP && do { $n = undef; last }) || $fsfile->tree(++$self->[TREE_NO]);
    last if $conditions->($n,$fsfile);
  }
  return $self->[NODE]=$n;
}
sub node {
  return $_[0]->[NODE];
}
sub file {
  return $_[0]->[FILE];
}
sub set_file {
  return $_[0]->[FILE]=$_[1];
}
sub reset {
  my ($self)=@_;
  $self->[NODE]=undef;
}

1; # End of PMLTQ::Relation::FSFileIterator

__END__

=pod

=encoding UTF-8

=head1 NAME

PMLTQ::Relation::FSFileIterator - Iterates nodes of given fsfile

=head1 VERSION

version 0.8.3

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
