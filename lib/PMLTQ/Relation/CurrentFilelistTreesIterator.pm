package PMLTQ::Relation::CurrentFilelistTreesIterator;

use 5.006;
use strict;
use warnings;
use base qw(PMLTQ::Relation::Iterator);
  use constant CONDITIONS=>0;
  use constant NODE=>1;
  
=head1 NAME

PMLTQ::Relation::CurrentFilelistTreesIterator

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';
    
our $PROGRESS; ### newly added
our $STOP; ### newly added  

=head1 SYNOPSIS

=head1 EXPORT

=head1 SUBROUTINES/METHODS

=cut

  sub start  {
    my ($self)=@_;
    TredMacro::GotoFileNo(0);
    $TredMacro::this=$TredMacro::root;
    $self->[NODE]=$TredMacro::this;
    my $fsfile = $TredMacro::grp->{FSFile};
    return ($TredMacro::this && $self->[CONDITIONS]->($TredMacro::this,$fsfile)) ? $TredMacro::this : ($TredMacro::this && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $conditions=$self->[CONDITIONS];
    my $n=$self->[NODE];
    my $fsfile = $TredMacro::grp->{FSFile};
    while ($n) {
      $n = $n->following
        || (($PROGRESS ? $PROGRESS->() : 1) && $STOP && do { $n = undef; last })
        ||  (TredMacro::NextFile() && ($fsfile=$TredMacro::grp->{FSFile}) && $TredMacro::this);
      last if $conditions->($n,$fsfile);
    }
    return $self->[NODE]=$n;
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub file {
    return $TredMacro::grp->{FSFile};
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
  }



=head1 AUTHOR

AUTHOR, C<< <AUTHOR at UFAL> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-pmltq-pml2base at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PMLTQ-PML2BASE>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PMLTQ::Relation::CurrentFilelistTreesIterator


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

1; # End of PMLTQ::Relation::CurrentFilelistTreesIterator
