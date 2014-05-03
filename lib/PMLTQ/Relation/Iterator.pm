package PMLTQ::Relation::Iterator;

use 5.006;
use strict;
use warnings;
use constant CONDITIONS=>0;
use Carp;

=head1 NAME

PMLTQ::Relation::Iterator

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

xxx

=head1 EXPORT

xxx

=head1 SUBROUTINES/METHODS

=over 4
=cut

=item PMLTQ::Relation::Iterator->new(conditions)

xxx

=cut
sub new {
    my ($class,$conditions)=@_;
    croak "usage: $class->new(sub{...})" unless ref($conditions) eq 'CODE';
    return bless [$conditions],$class;
  }

=item $iterator->clone()

xxx

=cut
  sub clone {
    my ($self)=@_;
    return bless [$self->[CONDITIONS]], ref($self);
  }

=item $iterator->conditions()

xxx

=cut
  sub conditions { return $_[0]->[CONDITIONS]; }

=item $iterator->set_conditions()

xxx

=cut
  sub set_conditions { $_[0]->[CONDITIONS]=$_[1]; }

=item $iterator->start()

xxx

=cut
  sub start {}

=item $iterator->next()

xxx

=cut
  sub next {}

=item $iterator->node()

xxx

=cut
  sub node {}

=item $iterator->reset()

xxx

=cut
  sub reset {}

=back

=cut

=head1 AUTHOR

AUTHOR, C<< <AUTHOR at UFAL> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-pmltq-pml2base at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PMLTQ-PML2BASE>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PMLTQ::Relation::Iterator


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

1; # End of PMLTQ::Relation::Iterator
