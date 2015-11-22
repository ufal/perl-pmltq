package PMLTQ::Relation;

# ABSTRACT: Base class for all Relations standard or user defined

use 5.006;
use strict;
use warnings;
use Carp;
use File::Spec;
use PMLTQ::Loader qw/find_modules load_class/;

my %user_defined;
my %start_to_target_type_map;

our @RELATIONS;

sub load {
  return if (@RELATIONS);

  @RELATIONS = find_modules('PMLTQ::Relation');

  load_class($_) for (@RELATIONS);
}

sub import {
  my $class=shift;
  for my $def (@_) {
    my $name = $def->{name};
    my $schema = $def->{schema};
    my $node_type = $def->{start_node_type};

    _relation($schema, $node_type, $name, $def);
  }
}

sub _relation {
  my ($schema_name, $node_type, $name, $def) = @_;
  if ($def) {
    $user_defined{ $schema_name }{ $node_type }{ $name } = $def;
    $start_to_target_type_map{ $schema_name }{ $node_type }{ $name } = $def->{target_node_type};
  }
  $user_defined{ $schema_name }{ $node_type }{ $name }
}

sub create_iterator {
  my ($class,$schema_name,$node_type,$label) = (shift,shift,shift,shift);
  my $rel = _relation($schema_name, $node_type, $label);
  if ($rel and exists($rel->{iterator_class})) {
    $rel->{iterator_class}->new(@_);
  } else {
    return;
  }
}

sub iterator_weight {
  my ($class,$schema_name,$node_type,$label) = @_;
  my $rel = _relation($schema_name, $node_type, $label);
  return unless $rel;
  return $rel && $rel->{iterator_weight};
}

sub relations_for_node_type {
  my ($class,$schema_name,$start_type)=@_;
  my $map = $start_to_target_type_map{$schema_name}{$start_type};
  return $map ? [sort keys %$map] : [];
}

sub relations_for_schema {
  my ($class, $schema_name) = @_;

  my $map = $user_defined{$schema_name};
  return $map ? [map { values %$_ } values %$map] : [];
}

sub target_type {
  my ($class,$schema_name,$start_type,$label)=@_;
  my $rel = $start_to_target_type_map{$schema_name}{$start_type};
  return $rel && $rel->{$label};
}

sub reversed_relation {
  my ($class, $schema_name, $start_type, $name)=@_;
  my $rel = _relation($schema_name, $start_type, $name);
  return $rel && $rel->{reversed_relation};
}

sub test_code {
  my ($class, $schema_name, $start_type, $name)=@_;
  my $rel = _relation($schema_name, $start_type, $name);
  return $rel && $rel->{test_code};
  return undef;
}

1; # End of PMLTQ::Relation
