package PMLTQ::Relation;

use 5.006;
use strict;
use warnings;
use Carp;
use File::Spec;
use File::Glob qw(:glob);

=head1 NAME

PMLTQ::Relation 

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';
my %user_defined;
my %start_to_target_type_map;


=for comment
# autoloading of relation modules
for my $dir (@INC) {
  next if ref $dir;
  for my $module (glob(File::Spec->catfile($dir,'PMLTQ','Relation','*.pm'))) {
    my $return = do $module;
    unless ($return) {
      if ($@) {
	warn "Failed to load PMLTQ::Relation submodule $module: $@\n";
      } elsif (!defined $return) {
	warn "Failed to compile PMLTQ::Relation submodule $module: $!\n";
      } elsif (!$return) {
	warn "PMLTQ::Relation submodule $module did not return a true value.\n";
      }
    }
  }
}
=cut
use PMLTQ::Relation::SimpleListIterator;
use PMLTQ::Relation::Iterator;


=head1 SYNOPSIS


=head1 EXPORT


=head1 SUBROUTINES/METHODS

=cut

sub import {
  my $class=shift;
  for my $def (@_) {
    my $name = $def->{name};
    $user_defined{ $def->{start_node_type}.':'.$name } = $def;
    $start_to_target_type_map{ $def->{start_node_type} }{ $name } = $def->{target_node_type};
  }
}

sub create_iterator {
  my ($class,$node_type,$label) = (shift,shift,shift);
  my $rel = $user_defined{ $node_type.':'.$label };
  if ($rel and exists($rel->{iterator_class})) {
    $rel->{iterator_class}->new(@_);
  } else {
    return;
  }
}

sub iterator_weight {
  my ($class,$node_type,$label) = @_;
  my $rel = $user_defined{$node_type.':'.$label};
  return unless $rel;
  return $rel && $rel->{iterator_weight};
}

sub relations_for_node_type {
  my ($class, $start_type)=@_;
  my $map = $start_to_target_type_map{$start_type};
  return $map ? [sort keys %$map] : [];
}

sub target_type {
  my ($class, $start_type,$label)=@_;
  my $rel = $start_to_target_type_map{$start_type};
  return $rel && $rel->{$label};
}

sub reversed_relation {
  my ($class, $start_type, $name)=@_;
  my $rel =  $user_defined{$start_type.':'.$name};
  return $rel && $rel->{reversed_relation};
}

sub test_code {
  my ($class, $start_type, $name)=@_;
  my $rel =  $user_defined{$start_type.':'.$name};
  return $rel && $rel->{test_code};
  return undef;
}

=head1 AUTHOR

AUTHOR, C<< <AUTHOR at UFAL> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-pmltq-pml2base at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PMLTQ-PML2BASE>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PMLTQ::Relation


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

1; # End of PMLTQ::Relation
