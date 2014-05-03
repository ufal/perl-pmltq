package PMLTQ::Relation::CurrentFileIterator;

use 5.006;
use strict;
use warnings;
  use Carp;
  use base qw(PMLTQ::Relation::Iterator);
  use constant CONDITIONS=>0;
  use constant NODE=>1;
  use constant FILE=>2;
  use constant TREE_NO=>3;
  use constant SCHEMA_ROOT_NAME=>4;
  use constant FILE_QUEUE=>5;
  use constant FIRST_FREE=>6;
=head1 NAME

PMLTQ::Relation::TreexFileIterator

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


  sub new {
    my ($class,$conditions,$schema_root_name)=@_;
    croak "usage: $class->new(sub{...})" unless ref($conditions) eq 'CODE';
    return bless [$conditions,undef,undef,0,$schema_root_name,[]],$class;
  }
  sub _next_file {
    my ($self)=@_;
    my $f;
    my $schema_name = $self->[SCHEMA_ROOT_NAME];
    while (@{$self->[FILE_QUEUE]}) {
      $f = shift @{$self->[FILE_QUEUE]};
      if ($f) {
        push @{$self->[FILE_QUEUE]}, TredMacro::GetSecondaryFiles($f);
        if (!defined($schema_name) or $schema_name eq PML::SchemaName($f)) {
          $self->[FILE]=$f;
          $self->[TREE_NO]=0;
          my $n = $self->[NODE] = $f->tree(0);
          return ($n && $self->[CONDITIONS]->($n,$f)) ? $n : ($n && $self->next)
        }
      }
    }
    return;
  }
  sub start  {
    my ($self)=@_;
    $self->[TREE_NO]=0;
    $self->[FILE_QUEUE] = [ TredMacro::CurrentFile() ];
    return $self->_next_file();
  }
  sub next {
    my ($self)=@_;
    my $conditions=$self->[CONDITIONS];
    my $n=$self->[NODE];
    my $f=$self->[FILE];
    while ($n) {
      $n = $n->following || (($PROGRESS ? $PROGRESS->() : 1) && $STOP && do { $n = undef; last }) || $f->tree(++$self->[TREE_NO]) || $self->_next_file();
      last if $conditions->($n,$f);
    }
    return $self->[NODE]=$n;
  }
  sub file {
    return $_[0]->[FILE];
  }
  sub node {
    return $_[0]->[NODE];
  }
  sub reset {
    my ($self)=@_;
    $self->[NODE]=undef;
    $self->[FILE]=undef;
    $self->[FILE_QUEUE]=undef;
    $self->[TREE_NO]=undef;
  }


=head1 AUTHOR

AUTHOR, C<< <AUTHOR at UFAL> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-pmltq-pml2base at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PMLTQ-PML2BASE>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PMLTQ::Relation::TreexFileIterator


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


1; # End of PMLTQ::Relation::CurrentFileIterator
