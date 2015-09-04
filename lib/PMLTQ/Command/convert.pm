package PMLTQ::Command::convert;
use PMLTQ::Command;

sub run {
  my $self = shift;
  my $config = PMLTQ::Command::load_config(shift);
  my $sqldir = shift;
  if(!-d $sqldir) {
    make_path($sqldir) or die "Unable to create directory $sqldir\n";
  }
  Treex::PML::AddResourcePath($config->{resources});
  for my $layer (@{$config->{layers}}) {
    print STDERR "==== Converting data for layer $layer->{name}\n";
    $PMLTQ::PML2BASE::opts{'no-secondary-files'} = 1;
    $PMLTQ::PML2BASE::opts{'resource-dir'} = $config->{resources};
    $PMLTQ::PML2BASE::opts{'related-schema'} = $layer->{'related-schema'} || [];
    $PMLTQ::PML2BASE::opts{'syntax'} = 'postgres';
    $PMLTQ::PML2BASE::opts{'loader'} = 'file_list'; # SH
    $PMLTQ::PML2BASE::opts{'data-dir'} = $config->{data_dir};
    $PMLTQ::PML2BASE::opts{'output-dir'} = $sqldir;
    %{$PMLTQ::PML2BASE::opts{'ref'}}=();
    $PMLTQ::PML2BASE::opts{'ref'}{$_} = $layer->{'references'}{$_} for (keys %{$layer->{'references'}||{}});
    PMLTQ::PML2BASE::init();

    #$PMLTQ::PML2BASE::opts{'debug'} = 1;

    # converting schema from pml2base.btred
    # PMLTQ::PML2BASE::convert_schema(Treex::PML::Factory->createPMLSchema({filename=>$opts{schema},use_resources=>1}),
    #                       {%opts, # $opts{ref} contains references
    #                        ($opts{'no-eparents'}&&$opts{'no-a-rf'}) ? () : (for_schema => \&mk_extra_tables),
    #                       });
    # PMLTQ::PML2BASE::dump_typemap();
    # end of converting schema


    for my $file (glob(File::Spec->catfile($config->{data_dir}, $layer->{data}))) {
      print STDERR "$file\n";
      my $fsfile = Treex::PML::Factory->createDocumentFromFile($file);
      if ($Treex::PML::FSError) {
        die "Error loading file $file: $Treex::PML::FSError ($!)\n";
      }
      PMLTQ::PML2BASE::fs2base($fsfile, {
                      for_each_tree => \&PMLTQ::Common::Effective::dump_eparent, ## TODO: not for all treebanks !!!
                      for_schema => \&PMLTQ::Common::Effective::mk_extra_tables  ##
                    });
    }
    PMLTQ::PML2BASE::finish();
    PMLTQ::PML2BASE::destroy();
  }
}


1;