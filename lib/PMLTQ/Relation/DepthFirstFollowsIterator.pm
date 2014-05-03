package PMLTQ::Relation::DepthFirstFollowsIterator;

use 5.006;
use strict;
use warnings;
  use base qw(PMLTQ::Relation::Iterator);
  use constant CONDITIONS=>0;
  use constant NODE=>1;
  use constant FILE=>2;

=head1 NAME

PMLTQ::Relation::DepthFirstFollowsIterator

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

=head1 EXPORT

=head1 SUBROUTINES/METHODS

=cut

  sub start  {
    my ($self,$parent,$fsfile)=@_;
    if ($fsfile) {
      $self->[FILE]=$fsfile;
    } else {
      $fsfile=$self->[FILE];
    }
    my $n= $parent->previous;
    $self->[NODE]=$n;
    return ($n && $self->[CONDITIONS]->($n,$fsfile)) ? $n : ($n && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $conditions=$self->[CONDITIONS];
    my $n=$self->[NODE]->previous();
    my $fsfile=$self->[FILE];
    $n=$n->previous() while ($n and !$conditions->($n,$fsfile));
    return $self->[NODE]=$n;
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub file {
    return $_[0]->[FILE];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
    $self->[FILE]=undef;
  }

=head1 AUTHOR

AUTHOR, C<< <AUTHOR at UFAL> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-pmltq-pml2base at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PMLTQ-PML2BASE>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PMLTQ::Relation::DepthFirstFollowsIterator


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

1; # End of PMLTQ::Relation::DepthFirstFollowsIterator
