package PMLTQ::Relation::SameTreeIterator;

use 5.006;
use strict;
use warnings;
  use Carp;
  use base qw(PMLTQ::Relation::TreeIterator);
  
=head1 NAME

PMLTQ::Relation::SameTreeIterator

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

=head1 EXPORT

=head1 SUBROUTINES/METHODS

=cut

  sub new  {
    my ($class,$conditions)=@_;
    croak "usage: $class->new(sub{...})" unless ref($conditions) eq 'CODE';
    return bless [$conditions],$class;
  }
  sub start  {
    my ($self,$root,$fsfile)=@_;
    $root=$root->root if $root;
    $self->[PMLTQ::Relation::TreeIterator::NODE] = $self->[PMLTQ::Relation::TreeIterator::TREE] = $root;
    $self->[PMLTQ::Relation::TreeIterator::FILE]=$fsfile;
    return ($root && $self->[PMLTQ::Relation::TreeIterator::CONDITIONS]->($root,$fsfile)) ? $root : ($root && $self->next);
  }

=head1 AUTHOR

AUTHOR, C<< <AUTHOR at UFAL> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-pmltq-pml2base at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PMLTQ-PML2BASE>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PMLTQ::Relation::SameTreeIterator


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=PMLTQ-PML2BASE>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/PMLTQ-PML2BASE>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/PMLTQ-PML2BASE>

=item * Search CPAN

L<http://search.cpan.org/dist/PMLTQ-PML2BASE/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2014 AUTHOR.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of PMLTQ::Relation::SameTreeIterator
