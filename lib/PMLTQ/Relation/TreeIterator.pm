package PMLTQ::Relation::TreeIterator;
<<<<<<< HEAD
our $AUTHORITY = 'cpan:MATY';
$PMLTQ::Relation::TreeIterator::VERSION = '1.2.3';
=======
our $AUTHORITY = 'cpan:MICHALS';
$PMLTQ::Relation::TreeIterator::VERSION = '1.1.0';
>>>>>>> 8de022e02ca25a48172558767e8e4ea04fb89b1c
# ABSTRACT: Evaluates condition on the whole tree of given node

use 5.006;
use strict;
use warnings;

use Carp;
use base qw(PMLTQ::Relation::Iterator);
use constant CONDITIONS=>0;
use constant TREE=>1;
use constant NODE=>2;
use constant FILE=>3;

sub new  {
  my ($class,$conditions,$root,$fsfile)=@_;
  croak "usage: $class->new(sub{...})" unless ref($conditions) eq 'CODE';
  return bless [$conditions,$root,undef,$fsfile],$class;
}
sub clone {
  my ($self)=@_;
  return bless [$self->[CONDITIONS],$self->[NODE],$self->[TREE],$self->[FILE]], ref($self);
}
sub start  {
  my ($self)=@_;
  my $root = $self->[NODE] = $self->[TREE];
  return ($root && $self->[CONDITIONS]->($root,$self->[FILE])) ? $root : ($root && $self->next);
}
sub next {
  my ($self)=@_;
  my $conditions=$self->[CONDITIONS];
  my $n=$self->[NODE];
  my $fsfile=$self->[FILE];
  while ($n) {
    $n = $n->following;
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
  $_[0]->[FILE] = $_[1];
}
sub set_tree {
  $_[0]->[TREE] = $_[1];
}
sub reset {
  my ($self)=@_;
  $self->[NODE]=undef;
}

1; # End of PMLTQ::Relation::TreeIterator

__END__

=pod

=encoding UTF-8

=head1 NAME

PMLTQ::Relation::TreeIterator - Evaluates condition on the whole tree of given node

=head1 VERSION

<<<<<<< HEAD
version 1.2.3
=======
version 1.1.0
>>>>>>> 8de022e02ca25a48172558767e8e4ea04fb89b1c

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
