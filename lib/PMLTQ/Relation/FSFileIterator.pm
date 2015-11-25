package PMLTQ::Relation::FSFileIterator;

# ABSTRACT: Iterates nodes of given fsfile

use 5.006;
use strict;
use warnings;

use Carp;
use base qw(PMLTQ::Relation::Iterator);
use constant CONDITIONS=>0;
use constant FILE=>1;
use constant TREE_NO=>2;
use constant TREES=>3;
use constant NODE=>4;
use constant TREEX_DOC=>5;

use PMLTQ::Loader 'load_class';

our $PROGRESS; ### newly added
our $STOP; ### newly added

sub new {
  my ($class,$conditions,$fsfile)=@_;
  croak "usage: $class->new(sub{...})" unless ref($conditions) eq 'CODE';
  my $obj = bless [$conditions],$class;
  $obj->set_file($fsfile) if $fsfile;
  return $obj;
}
sub clone {
  my ($self)=@_;
  return bless [$self->[CONDITIONS],$self->[FILE]], ref($self);
}
sub tree {
  my ($self, $n)=@_;
  return $self->[TREES]->[$n];
}
sub start  {
  my ($self,undef,$fsfile)=@_;
  $self->[TREE_NO]=0;
  if ($fsfile) {
    $self->set_file($fsfile);
  } else {
    $fsfile=$self->[FILE];
  }
  my $n = $self->[NODE] = $self->tree(0);
  return ($n && $self->[CONDITIONS]->($n,$fsfile)) ? $n : ($n && $self->next);
}
sub next {
  my ($self)=@_;
  my $conditions=$self->[CONDITIONS];
  my $n=$self->[NODE];
  my $fsfile=$self->[FILE];
  while ($n) {
    # Treex has following hacked but we want to have classic following
    $n = Treex::PML::Node::following($n) || (($PROGRESS ? $PROGRESS->() : 1) && $STOP && do { $n = undef; last }) || $self->tree(++$self->[TREE_NO]);
    last if $conditions->($n,$fsfile);
  }
  return $self->[NODE]=$n;
}
sub node {
  return $_[0]->[NODE];
}
sub file {
  return $_[0]->[FILE];
}
sub set_file {
  my ($self, $file) = @_;
  $self->[FILE] = $file;
  my $schema_name = $file->schema->get_root_name;

  if ($schema_name && $schema_name eq 'treex_document') {
    die "Please install Treex::Core if you want to use PML-TQ with treex files\n" unless load_class('Treex::Core::Document');
    $self->[TREEX_DOC] = Treex::Core::Document->new({pmldoc => $file}); # Will convert the file to Treex Document in place
    $self->_extract_trees;
  } else {
    $self->[TREES] = [$file->trees];
  }
  return $file;
}
sub reset {
  my ($self)=@_;
  $self->[NODE]=undef;
}

sub _extract_trees {
  my ($self)=@_;
  my $doc = $self->[TREEX_DOC];
  # lets assume it's a treex doc
  $self->[TREES] = [];
  foreach my $bundle ($doc->get_bundles) {
    last unless defined $bundle->{zones};
    foreach my $zone ($bundle->get_all_zones) {
      push @{$self->[TREES]}, $zone->get_all_trees;
    }
  }
}

1; # End of PMLTQ::Relation::FSFileIterator
