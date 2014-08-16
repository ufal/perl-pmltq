package PMLTQ::Relation::MemberIterator;

use 5.006;
use strict;
use warnings;

use base qw(PMLTQ::Relation::SimpleListIterator);
use constant ATTR => PMLTQ::Relation::SimpleListIterator::FIRST_FREE;
use Carp;

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
  #print STDERR "MemberIterator attr: $self->[ATTR]\n";
  return [map [$_,$fsfile], Treex::PML::Instance::get_all($node,$self->[ATTR])];

}

1; # End of PMLTQ::Relation::MemberIterator

__END__

=pod

=head1 NAME

PMLTQ::Relation::MemberIterator

=cut
