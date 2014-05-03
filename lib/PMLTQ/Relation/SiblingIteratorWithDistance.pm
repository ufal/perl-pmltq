package PMLTQ::Relation::SiblingIteratorWithDistance;

use 5.006;
use strict;
use warnings;
use base qw(PMLTQ::Relation::Iterator);
  use Carp;
  use constant CONDITIONS=>0;
  use constant MIN=>1;
  use constant MAX=>2;
  use constant NODE=>3;
  use constant DIST=>4;
  use constant FILE=>5;
  use constant START=>6;
  
=head1 NAME

PMLTQ::Relation::SiblingIteratorWithDistance

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

=head1 EXPORT

=head1 SUBROUTINES/METHODS


=cut

sub new  {
    my ($class,$conditions,$min,$max)=@_;
    croak "usage: $class->new(sub{...})" unless ref($conditions) eq 'CODE';
    $min||=0;
    return bless [$conditions,$min,$max],$class;
  }
  sub clone {
    my ($self)=@_;
    return bless [$self->[CONDITIONS],$self->[MIN],$self->[MAX]], ref($self);
  }
  # the iterator will first go right from the start node,
  # then left
  sub start  {
    my ($self,$node,$fsfile)=@_;
    my $min = $self->[MIN];
    my $max = $self->[MAX];
    $self->[FILE]=$fsfile;
    $self->[START]=$node;
    # -10, means -10 to +infty
    # -10,0 means in fact -10,-1
    # ,10, means -infty to 10,
    # 0,10 means 1,10
    # ,-10 means -infty to -10
    # N,M with N=M=0 or M<N is never satisfied
    return if (defined($min) and defined($max) and $min>$max);
    my $dist=1;
    my $n=$node->rbrother;
    if (defined($min) and $min>$dist) {
      $n = $n->rbrother while ($n and ($dist++)<$min);
    }
    $n=undef if defined($max) and $dist>$max;
    if (!$n) { # try going left
      $dist = -1;
      $n=$node->lbrother;
      if (defined($max) and $max<$dist) {
        $n = $n->lbrother while ($n and ($dist--)>$max);
      }
      $n=undef if defined($min) and $dist<$min;
    }
    $self->[NODE]=$n;
    $self->[DIST]=$dist;
    return ($n && $self->[CONDITIONS]->($n,$fsfile)) ? $n : ($n && $self->next);
  }
  sub next {
    my ($self)=@_;
    my $conditions=$self->[CONDITIONS];
    my $max = $self->[MAX];
    my $min = $self->[MIN];
    my $dist = $self->[DIST];
    my $fsfile = $self->[FILE];
    my $n=$self->[NODE];
    if ($dist>0) {
      # advance right
      while ($n) {
        $n=$n->rbrother;
        $dist++;
        last if defined($max) and $dist>$max;
        if ($conditions->($n,$fsfile)) {
          $self->[DIST]=$dist;
          return $self->[NODE]=$n;
        }
      }
      # return to start node
      $dist = 0;
      $n=$self->[START];
      if (defined($max) and $max+1<$dist) {
        $n = $n->lbrother while ($n and $max+1<$dist--);
      }
    }
    # advance left
    while ($n) {
      $n=$n->lbrother;
      $dist--;
      last if defined($min) and $dist<$min;
      if ($conditions->($n,$fsfile)) {
        $self->[DIST]=$dist;
        return $self->[NODE]=$n;
      }
    }
    $self->[DIST]=0;
    return $_[0]->[NODE]=undef;
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
    $self->[DIST]=0;
  }


=head1 AUTHOR

AUTHOR, C<< <AUTHOR at UFAL> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-pmltq-pml2base at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PMLTQ-PML2BASE>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PMLTQ::Relation::SiblingIteratorWithDistance


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

1; # End of PMLTQ::Relation::SiblingIteratorWithDistance
