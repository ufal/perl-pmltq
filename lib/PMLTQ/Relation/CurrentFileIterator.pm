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

our $PROGRESS; ### newly added
our $STOP; ### newly added

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

1; # End of PMLTQ::Relation::CurrentFileIterator
