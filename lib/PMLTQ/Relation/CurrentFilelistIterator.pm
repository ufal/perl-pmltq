package PMLTQ::Relation::CurrentFilelistIterator;
<<<<<<< HEAD
<<<<<<< HEAD
our $AUTHORITY = 'cpan:MATY';
$PMLTQ::Relation::CurrentFilelistIterator::VERSION = '1.2.3';
=======
our $AUTHORITY = 'cpan:MICHALS';
$PMLTQ::Relation::CurrentFilelistIterator::VERSION = '1.1.0';
>>>>>>> 8de022e02ca25a48172558767e8e4ea04fb89b1c
=======
our $AUTHORITY = 'cpan:MICHALS';
$PMLTQ::Relation::CurrentFilelistIterator::VERSION = '1.1.0';
>>>>>>> 8de022e02ca25a48172558767e8e4ea04fb89b1c
# ABSTRACT: Iterates over files of given file list (calling TredMacro::NextFile())

use 5.006;
use strict;
use warnings;

use base qw(PMLTQ::Relation::CurrentFileIterator);

our $PROGRESS; ### newly added
our $STOP; ### newly added

sub next {
    my ($self)=@_;
    my $conditions=$self->[PMLTQ::Relation::CurrentFileIterator::CONDITIONS];
    my $n=$self->[PMLTQ::Relation::CurrentFileIterator::NODE];
    my $f=$self->[PMLTQ::Relation::CurrentFileIterator::FILE];
    while ($n) {
      $n = $n->following
        || (($PROGRESS ? $PROGRESS->() : 1) && $STOP && do { $n = undef; last })
        || $f->tree(++$self->[PMLTQ::Relation::CurrentFileIterator::TREE_NO])
        || $self->_next_file();
      unless ($n) {
        while (TredMacro::NextFile()) {
          $self->[PMLTQ::Relation::CurrentFileIterator::TREE_NO]=0;
          $f = $TredMacro::grp->{FSFile};
          $self->[PMLTQ::Relation::CurrentFileIterator::FILE_QUEUE] = [$f];
          $n = $self->_next_file();
          last if $n;
        }
      }
      last if $conditions->($n,$f);
    }
    return $self->[PMLTQ::Relation::CurrentFileIterator::NODE]=$n;
  }

1; # End of PMLTQ::Relation::CurrentFilelistIterator

__END__

=pod

=encoding UTF-8

=head1 NAME

PMLTQ::Relation::CurrentFilelistIterator - Iterates over files of given file list (calling TredMacro::NextFile())

=head1 VERSION

<<<<<<< HEAD
<<<<<<< HEAD
version 1.2.3
=======
version 1.1.0
>>>>>>> 8de022e02ca25a48172558767e8e4ea04fb89b1c
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
