package PMLTQ::Command::convert;

# ABSTRACT: Converts PML files to SQL

use PMLTQ::Base 'PMLTQ::Command';

use File::Path qw( make_path );
use PMLTQ::Command;
use PMLTQ::PML2BASE;
use Treex::PML;

has usage => sub { shift->extract_usage };

sub run {
  my $self = shift;

  my $config = $self->config;
  my $output_dir = $config->{output_dir};

  unless (-d $output_dir) {
    make_path($output_dir) or die "Unable to create directory $output_dir\n";
  }

  Treex::PML::AddResourcePath($config->{resources});

  unless (@{$config->{layers}} > 0) {
    print STDERR 'Nothing to convert, no layers configured';
    return
  }

  for my $layer (@{$config->{layers}}) {
    print STDERR "==== Converting data for layer $layer->{name}\n";

    $PMLTQ::PML2BASE::opts{'no-secondary-files'} = 1;
    $PMLTQ::PML2BASE::opts{'resource-dir'} = $config->{resources};
    $PMLTQ::PML2BASE::opts{'related-schema'} = $layer->{'related-schema'} || [];
    $PMLTQ::PML2BASE::opts{'syntax'} = 'postgres'; ### TODO REMOVE
    $PMLTQ::PML2BASE::opts{'loader'} = 'file_list'; # SH ### TODO REMOVE
    $PMLTQ::PML2BASE::opts{'data-dir'} = $config->{data_dir};
    $PMLTQ::PML2BASE::opts{'output-dir'} = $output_dir;
    %{$PMLTQ::PML2BASE::opts{'ref'}}=();
    $PMLTQ::PML2BASE::opts{'ref'}{$_} = $layer->{'references'}{$_} for (keys %{$layer->{'references'}||{}});
    PMLTQ::PML2BASE::init();

    for my $file (glob(File::Spec->catfile($config->{data_dir}, $layer->{data}))) {
      print STDERR "$file\n";
      my $fsfile = Treex::PML::Factory->createDocumentFromFile($file);
      if ($Treex::PML::FSError) {
        die "Error loading file $file: $Treex::PML::FSError ($!)\n";
      }
      PMLTQ::PML2BASE::fs2base($fsfile);
    }
    PMLTQ::PML2BASE::finish();
    PMLTQ::PML2BASE::destroy();
  }
  return 1;
}

1;

=head1 SYNOPSIS

  pmltq convert [--config treebank_config]

=head1 DESCRIPTION

Convert from PML to SQL.

=head1 OPTIONS

=over 5

=item B<treebank_config>

Path to configuration file. If a treebank_config is --, config is read from STDIN.

=back

=cut

