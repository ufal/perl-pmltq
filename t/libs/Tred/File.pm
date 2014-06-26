package Tred::File;

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

1;