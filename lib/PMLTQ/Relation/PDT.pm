package PMLTQ::Relation::PDT;
#
# This file implements the following user-defined relations for PML-TQ
#
# - a/lex.rf|a/aux.rf
# - eparent (both t-layer and a-layer)
# - echild (both t-layer and a-layer)
#
#################################################

{
  package PMLTQ::Relation::PDT::PML_A;
=item DiveAuxCP($node)

You can use this function as a C<through> argument to GetEParents and
GetEChildren. It skips all the prepositions and conjunctions when
looking for nodes which is what you usually want.

=cut

  sub DiveAuxCP ($){
    $_[0]->{afun}=~/^Aux[CP]/ ? 1 : 0;
  }#DiveAuxCP

=item GetEParents($node,$through)

Return linguistic parent of a given node as appears in an analytic
tree. The argument C<$through> should supply a function accepting one
node as an argument and returning true if the node should be skipped
on the way to parent or 0 otherwise. The most common C<DiveAuxCP> is
provided in this package.

=cut

  sub _ExpandCoordGetEParents { # node through
    my ($node,$through)=@_;
    my @toCheck = $node->children;
    my @checked;
    while (@toCheck) {
      @toCheck=map {
        if (&$through($_)) { $_->children() }
        elsif($_->{afun}=~/Coord|Apos/&&$_->{is_member}){ _ExpandCoordGetEParents($_,$through) }
        elsif($_->{is_member}){ push @checked,$_;() }
        else{()}
      }@toCheck;
    }
    return @checked;
  }# _ExpandCoordGetEParents

  sub GetEParents { # node through
    my ($node,$through)=@_;
    my $init_node = $node; # only used for reporting errors
    return() if !$node or $node->{afun}=~/^(?:Coord|Apos|Aux[SCP])$/;
    if ($node->{is_member}) { # go to coordination head
      while ($node->{afun}!~/Coord|Apos|AuxS/ or $node->{is_member}) {
        $node=$node->parent;
        if (!$node) {
    print STDERR
      "GetEParents: Error - no coordination head $init_node->{AID}: ".ThisAddress($init_node)."\n";
          return();
        } elsif($node->{afun}eq'AuxS') {
    print STDERR
      "GetEParents: Error - no coordination head $node->{AID}: ".ThisAddress($node)."\n";
          return();
        }
      }
    }
    if (&$through($node->parent)) { # skip 'through' nodes
      while ($node and &$through($node->parent)) {
        $node=$node->parent;
      }
    }
    return unless $node;
    $node=$node->parent;
    return unless $node;
    return $node if $node->{afun}!~/Coord|Apos/;
    _ExpandCoordGetEParents($node,$through);
  } # GetEParents
} 



{
  package PMLTQ::Relation::PDT::PML_T;
=item ExpandCoord($node,$keep?)

If the given node is coordination or aposition (according to its TGTS
functor - attribute C<functor>) expand it to a list of coordinated
nodes. Otherwise return the node itself. If the argument C<keep> is
true, include the coordination/aposition node in the list as well.

=cut

  sub ExpandCoord {
    my ($node,$keep)=@_;
    return unless $node;
    if (IsCoord($node)) {
      return (($keep ? $node : ()),
        map { ExpandCoord($_,$keep) }
        grep { $_->{is_member} } $node->children);
    } else {
      return ($node);
    }
  } #ExpandCoord

=item IsCoord($node?)

Check if the given node is a coordination according to its TGTS
functor (attribute C<functor>)

=cut

  sub IsCoord {
    my $node=$_[0];# || $this;
    return 0 unless $node;
    return 0 if $node->{nodetype} eq 'root'; # root does not have functor !!!
    return $node->{functor} =~ /ADVS|APPS|CONFR|CONJ|CONTRA|CSQ|DISJ|GRAD|OPER|REAS/;
  }

=item GetEParents($node)

Return linguistic parents of a given node as appear in a TG tree.

=cut

  sub GetEParents {
    my $node = $_[0];# || $this;
    return() if IsCoord($node);
    if ($node and $node->{is_member}) {
      while ($node and (!IsCoord($node) or $node->{is_member})) {
        $node=$node->parent;
      }
    }
    return () unless $node;
    $node=$node->parent;
    return () unless $node;
    return ($node) if !IsCoord($node);
    return (ExpandCoord($node));
  } # GetEParents
}

1;

