package TredMacro;
{
  package TrEd::File;
  sub get_secondary_files {
    my ($fsfile) = @_;
    # is probably the same as Treex::PML::Document->relatedDocuments()
    # a reference to a list of pairs (id, URL)
    my $requires = $fsfile->metaData('fs-require');
    my @secondary;
    if ($requires) {
      foreach my $req (@$requires) {
        my $id = $req->[0];
        my $req_fs
          = ref( $fsfile->appData('ref') )
            ? $fsfile->appData('ref')->{$id}
            : undef;
        if ( UNIVERSAL::DOES::does( $req_fs, 'Treex::PML::Document' ) ) {
          push( @secondary, $req_fs );
        }
      }
    }
    return uniq(@secondary);
  }  

  sub get_backends {
    return ();
  }    
  #######################################################################################
  # Usage         : uniq(@array)
  # Purpose       : Remove duplicit elements from array
  # Returns       : Array without repeating elements
  # Parameters    : array @arr  -- array to be uniqued
  # Throws        : no exception
  # Comments      : Preserves type and order of elements, as suggested by Perl best practices
  sub uniq {
    # seen -- track keys already seen elements
    my %seen;
    # return only those not yet seen
    return grep { !( $seen{$_}++ ) } @_;
  }
}

=item C<GetSecondaryFiles($fsfile?)>

Return a list of secondary L<Treex::PML::Document|http://search.cpan.org/dist/Treex-PML/lib/Treex/PML/Document.pm> objects for the given (or current)
file.  A secondary file is a file required by a file to be loaded
along with it; this is typical for files containing some form of a
stand-off annotation where one tree is built upon another. Note
however, that this does not include so called knitting - an operation
where the stand-off annotation is handled by a IO backend and the
resulting knitted file appears to btred as a single unit.
Only those secondary files that are already open are returned.

=cut

sub GetSecondaryFiles {
    my ($fsfile) = @_;
    $fsfile ||= CurrentFile();
    return
        exists(&TrEd::File::get_secondary_files)
        ? TrEd::File::get_secondary_files($fsfile)
        : ();
}

=item C<Backends()>

Return a list of currently registered I/O backends.

=cut

sub Backends {
    return ();#TrEd::File::get_backends();
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

1;
