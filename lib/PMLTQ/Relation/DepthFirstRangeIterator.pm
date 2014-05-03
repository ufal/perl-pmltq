package PMLTQ::Relation::DepthFirstRangeIterator;

use 5.006;
use strict;
use warnings;
  use Carp;
  use base qw(PMLTQ::Relation::Iterator);
  use constant CONDITIONS=>0;
  use constant LMIN =>1;
  use constant LMAX =>2;
  use constant RMIN =>3;
  use constant RMAX =>4;
  use constant DIST =>5;
  use constant NODE=>6;
  use constant FILE=>7;
  use constant START=>8;
  
=head1 NAME

PMLTQ::Relation::DepthFirstRangeIterator

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

 This iterator returns nodes preceding the start node
 if their depth-first-order distance from it falls into the range [-LMAX,-LMIN]
 and following the start node in their depth-first-order distance from
 it falls into the range [RMIN,RMAX]; note that the arguments for LMIN,LMAX
 must be negative values.
 For example, given (LMIN,LMAX,RMIN,RMAX) = (-1,-3,1,4), the iterator returns
 first three nodes preceding and first four nodes following the start node

=head1 EXPORT

=head1 SUBROUTINES/METHODS


=cut



  sub new  {
    my ($class,$conditions,$lmin,$lmax,$rmin,$rmax)=@_;
    croak "usage: $class->new(sub{...})" unless ref($conditions) eq 'CODE';
    return bless [$conditions,$lmin,$lmax,$rmin,$rmax],$class;
  }
  sub clone {
    my ($self)=@_;
    return bless [$self->[CONDITIONS],$self->[LMIN],$self->[LMAX],$self->[RMIN],$self->[RMAX]], ref($self);
  }
  sub start  {
    my ($self,$start_node,$fsfile)=@_;
    if ($fsfile) {
      $self->[FILE]=$fsfile;
    } else {
      $fsfile=$self->[FILE];
    }
    $self->[START] = $start_node;
    my $n;
    my $dist=0;
    my $rmin = $self->[RMIN];
    if (defined($rmin)) {
      $n=$start_node;
      while ($n and $dist<$rmin) {
        $n = $n->following;
        $dist++;
      }
      my $rmax = $self->[RMAX];
      undef $n if ($n and defined($rmax) and $dist>$rmax);
    }
    if (!$n) {
      my $lmin = $self->[LMIN];
      if (defined($lmin)) {
        $dist=0;
        $n=$start_node;
        while ($n and $dist>$lmin) {
          $n = $n->previous;
          $dist--;
        }
        my $lmax = $self->[LMAX];
        undef $n if ($n and defined($lmax) and $dist<$lmax);
      }
    }
    $self->[DIST]=$dist;
    $self->[NODE]=$n;
    return ($n && $self->[CONDITIONS]->($n,$fsfile)) ? $n : ($n && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $conditions=$self->[CONDITIONS];
    my $n=$self->[NODE];
    my $fsfile=$self->[FILE];
    my $dist=$self->[DIST];

    my $max;
    if ($dist>0) {
      # advance right
      $max=$self->[RMAX];
      while ($n) {
        $dist++;
        last if (defined($max) and $dist>$max);
        $n=$n->following();
        if ($conditions->($n,$fsfile)) {
          $self->[DIST]=$dist;
          return $self->[NODE]=$n;
        }
      }
      my $lmin = $self->[LMIN];
      unless (defined $lmin) {
        $self->[DIST]=$dist;
        return($self->[NODE]=undef);
      }
      $dist = 0;
      $n = $self->[START];
      while ($n and ($dist-1) > $lmin) {
        $n = $n->previous;
        $dist--;
      }
    }
    # advance left
    $max = $self->[LMAX];
    while ($n) {
      $dist--;
      if (defined($max) and $dist<$max) {
        undef $n;
        last;
      }
      $n=$n->previous();
      last if $conditions->($n,$fsfile);
    }
    $self->[DIST]=$dist;
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
    $self->[START]=undef;
    $self->[DIST]=undef;
  }

=head1 AUTHOR

AUTHOR, C<< <AUTHOR at UFAL> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-pmltq-pml2base at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PMLTQ-PML2BASE>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PMLTQ::Relation::DepthFirstRangeIterator


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

1; # End of PMLTQ::Relation::DepthFirstRangeIterator
