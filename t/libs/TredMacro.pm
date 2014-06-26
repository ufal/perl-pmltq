package TredMacro;

### DOIMPLEMENTOVAT POTŘEBNÉ METODY
#use lib ('/home/matyas/Documents/UFAL/PMLTQ/tredlib');
#use TrEd::Basics;
#use TrEd::MacroAPI::Default;
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
  shift if !ref $_[0];
  print STDERR "\t\tCurrentFile\t\tCALL:\t",join(" ",caller),"\n";
  my $win = shift || $grp;
  if ($win) {
    return $win->{FSFile};
  }
}



sub ThisAddress {
  print STDERR "\t\tThisAddress\t\tCALL:\t",join(" ",caller),"\n";
  my ( $f, $i, $n, $id ) = &LocateNode;
  if ( $i == 0 and $id ) {
    return $f . '#' . $id;
  }
  else {
    return $f . '##' . $i . '.' . $n;
  }
}

   
sub LocateNode {
  print STDERR "\t\tLocateNode\t\tCALL:\t",join(" ",caller),"\n";
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
  print STDERR "\t\tGetNodeIndex\t\tCALL:\t",join(" ",caller),"\n";
  my $node = ref( $_[0] ) ? $_[0] : $this;
  my $i = -1;
  while ($node) {
    $node = $node->previous();
    $i++;
  }
  return $i;
}

=x
sub DetermineNodeType {
  my ($node)=@_;
  print STDERR "\t\tDetermineNodeType\t\tCALL:\t",join(" ",caller),"\n";
  Treex::PML::Document->determine_node_type($node);
}  
=cut

1;