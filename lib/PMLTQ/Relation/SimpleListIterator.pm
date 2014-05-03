package PMLTQ::Relation::SimpleListIterator;

use 5.006;
use strict;
use warnings;
use base qw(PMLTQ::Relation::Iterator);
  use constant CONDITIONS=>0;
  use constant NODES=>1;
  use constant FILE=>2;
  use constant FIRST_FREE=>3; # number of the first constant free for user
  
  
=head1 NAME

PMLTQ::Relation::SimpleListIterator

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS


=head1 EXPORT


=head1 SUBROUTINES/METHODS


=cut


sub start  {
    my ($self,$node,$fsfile)=@_;
    $self->[FILE]=$fsfile;
    my $nodes = $self->[NODES] = $self->get_node_list($node);
    my $n = $nodes->[0];
    return ($n && $self->[CONDITIONS]->(@$n)) ? $n->[0] : ($n->[0] && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $nodes = $self->[NODES];
    my $conditions=$self->[CONDITIONS];
    shift @{$nodes};
    my $n;
    while (($n = $nodes->[0]) and !$conditions->(@$n)) {
      shift @{$nodes};
    }
    return $nodes->[0][0];
  }
  sub node {
    my ($self)=@_;
    my $n = $self->[NODES][0];
    return $n && $n->[0];
  }
  sub file {
    my ($self)=@_;
    my $n = $self->[NODES][0];
    return $n && $n->[1];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODES]=undef;
    $self->[FILE]=undef;
  }
  sub get_node_list {
    return [];
  }
  sub start_file {
    my ($self)=@_;
    return $self->[FILE];
  }


=head1 AUTHOR

AUTHOR, C<< <AUTHOR at UFAL> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-pmltq-pml2base at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PMLTQ-PML2BASE>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PMLTQ::Relation::SimpleListIterator


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

1; # End of PMLTQ::Relation::SimpleListIterator
