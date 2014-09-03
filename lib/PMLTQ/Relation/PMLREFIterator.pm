package PMLTQ::Relation::PMLREFIterator;

# ABSTRACT: Iterates over PML reference

use 5.006;
use strict;
use warnings;

use base qw(PMLTQ::Relation::SimpleListIterator);
use constant ATTR => PMLTQ::Relation::SimpleListIterator::FIRST_FREE;
use Carp;

my $can_open_secondary = exists(&TredMacro::OpenSecondaryFiles);

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

1; # End of PMLTQ::Relation::PMLREFIterator
