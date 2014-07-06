package TredMacro;

  #####################
  # Code to provide stuff required from btred
  #####################

### DOIMPLEMENTOVAT POTŘEBNÉ METODY
#use lib ('/home/matyas/Documents/UFAL/PMLTQ/tredlib');
#use TrEd::Basics;
use TrEd::MacroAPI::Default;
#no warnings qw(redefine);
sub reset {
  #$grp = undef;
  #$this = undef;
  #$root = undef;
}

sub Backends {
  return ();
}

sub GetSecondaryFiles {
  my ($fsfile) = @_;
  $fsfile ||= CurrentFile(); ### TODO ???
  return
      exists(&TrEd::File::get_secondary_files) 
      ? TrEd::File::get_secondary_files($fsfile)
      : ();
}

sub CurrentFile {
  return;
=xx  
  shift if !ref $_[0];
  my $win = shift || $grp;
  if ($win) {
    return $win->{FSFile};
  }
=cut  
}

=item C<ThisAddress(node?,fsfile?)>

Return a given node's address string in a form of
filename#tree_no.index (tree_no starts from 1 to reflect TrEd's UI
convention).  If the correct tree number could not be determined (the
node does not belong to any top-level tree in the file) and the node
has an ID, the address is returned in the form filename#ID.

If C<node> is not given, C<$this> is assumed. Should the node be from a
different file than the current one, the second argument must specify
the corresponding L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm> object.

=cut

sub ThisAddress {
    my ( $f, $i, $n, $id ) = &LocateNode;
    if ( $i == 0 and $id ) {
        return $f . '#' . $id;
    }
    else {
        return $f . '##' . $i . '.' . $n;
    }
}
   
sub LocateNode {
  my $node
    = ref( $_[0] ) ? $_[0]
    : @_           ? confess("Cannot get position of an undefined node")
    :                $this;
  my $fsfile = ref( $_[1] ) ? $_[1] : CurrentFile();
  return unless ref $node;
  my $tree = $node->root;  
  if ( $fsfile == CurrentFile() and $tree == $root ) { ## $root is not initialized !!!
    return ( FileName(), CurrentTreeNumber() + 1, GetNodeIndex($node) );
  }
  else {
    my $i = 1;
    foreach my $t ( $fsfile->trees ) {
        if ( $t == $tree ) {
            return ( $fsfile->filename, $i, GetNodeIndex($node) );
        }
        $i++;
    }
    my $type = $node->type;
    my ($id_attr) = $type && $type->find_members_by_role('#ID');
    return ( $fsfile->filename, 0, GetNodeIndex($node),
        $id_attr && $node->{ $id_attr->get_name } );
  }
}


sub GetNodeIndex {
  my $node = ref( $_[0] ) ? $_[0] : $this;
  my $i = -1;
  while ($node) {
    $node = $node->previous();
    $i++;
  }
  return $i;
}


sub DetermineNodeType {
  my ($node)=@_;
  Treex::PML::Document->determine_node_type($node);
}  


1;