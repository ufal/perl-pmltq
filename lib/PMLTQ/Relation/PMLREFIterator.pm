package PMLTQ::Relation::PMLREFIterator;

use 5.006;
use strict;
use warnings;
use base qw(PMLTQ::Relation::SimpleListIterator);
use constant ATTR => PMLTQ::Relation::SimpleListIterator::FIRST_FREE;
use Carp;
  
=head1 NAME

PMLTQ::Relation::PMLREFIterator

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';
my $can_open_secondary = exists(&TredMacro::OpenSecondaryFiles);

=head1 SYNOPSIS

=head1 EXPORT

=head1 SUBROUTINES/METHODS


=cut
sub new {
    my ($class,$conditions,$attr)=@_;
    croak "usage: $class->new(sub{...},\$attr)" unless (ref($conditions) eq 'CODE' and defined $attr);
    my $self = PMLTQ::Relation::SimpleListIterator->new($conditions);
    $self->[ATTR]=$attr;
    bless $self, $class; # reblessing
    return $self;
  }
  sub clone {
    my ($self)=@_;
    my $clone = $self->PMLTQ::Relation::SimpleListIterator::clone();
    $clone->[ATTR]=$self->[ATTR];
    return $clone;
  }
  sub get_node_list  {
    my ($self,$node)=@_;
    my $fsfile = $self->[PMLTQ::Relation::SimpleListIterator::FILE];
    return [map {
      my $id = $_;
      if ($id=~s{^(.*)?#}{} and defined($1) and length($1)) {
        unless (ref $fsfile) {
          Carp::confess("No fsfile!");
        }
        my $refs = $fsfile->appData('ref');
        my $ref_fs = $refs && $refs->{$1};
        if (!$ref_fs and $can_open_secondary) {
          TredMacro::OpenSecondaryFiles($fsfile);
          $refs = $fsfile->appData('ref');
          $ref_fs = $refs && $refs->{$1};
        }
        my $n = $ref_fs && PML::GetNodeByID($id,$ref_fs);
        $ref_fs && $n ? [$n, $ref_fs] : ();
      } else {
        my $n = PML::GetNodeByID($id,$fsfile);
        $n ? [$n, $fsfile] : ()
      }
    } Treex::PML::Instance::get_all($node,$self->[ATTR])];
  }

=head1 AUTHOR

AUTHOR, C<< <AUTHOR at UFAL> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-pmltq-pml2base at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PMLTQ-PML2BASE>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PMLTQ::Relation::PMLREFIterator


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

1; # End of PMLTQ::Relation::PMLREFIterator
