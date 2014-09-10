package PMLTQ::Relation;
BEGIN {
  $PMLTQ::Relation::AUTHORITY = 'cpan:MICHALS';
}
$PMLTQ::Relation::VERSION = '0.8.2';
# ABSTRACT: Base class for all Relations standard or user defined

use 5.006;
use strict;
use warnings;
use Carp;
use File::Spec;
use File::Glob qw(:glob);

my %user_defined;
my %start_to_target_type_map;

use PMLTQ::Relation::SimpleListIterator;
use PMLTQ::Relation::Iterator;

# for my $dir (@INC) {
#   next if ref $dir;
#   for my $module (glob(File::Spec->catfile($dir,'PMLTQ','Relation','*.pm'))) {
#     my $return = do $module;
#     unless ($return) {
#       if ($@) {
#   warn "Failed to load PMLTQ::Relation submodule $module: $@\n";
#       } elsif (!defined $return) {
#   warn "Failed to compile PMLTQ::Relation submodule $module: $!\n";
#       } elsif (!$return) {
#   warn "PMLTQ::Relation submodule $module did not return a true value.\n";
#       }
#     }
#   }
# }

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

1; # End of PMLTQ::Relation

__END__

=pod

=encoding UTF-8

=head1 NAME

PMLTQ::Relation - Base class for all Relations standard or user defined

=head1 VERSION

version 0.8.2

=head1 AUTHORS

=over 4

=item *

Petr Pajas <pajas@ufal.mff.cuni.cz>

=item *

Jan Štěpánek <stepanek@ufal.mff.cuni.cz>

=item *

Michal Sedlák <sedlak@ufal.mff.cuni.cz>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Institute of Formal and Applied Linguistics (http://ufal.mff.cuni.cz).

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
