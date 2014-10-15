package PMLTQ::Relation;

# ABSTRACT: Base class for all Relations standard or user defined

use 5.006;
use strict;
use warnings;
use Carp;
use File::Spec;
use File::Glob qw(:glob);
use PMLTQ::Loader;

my %user_defined;
my %start_to_target_type_map;

our @RELATIONS = PMLTQ::Loader->search('PMLTQ::Relation');

PMLTQ::Loader->load($_) for (@RELATIONS);

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