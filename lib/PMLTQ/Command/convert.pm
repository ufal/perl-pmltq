package PMLTQ::Command::convert;

# ABSTRACT: Converts PML files to sql

use strict;
use warnings;

use Treex::PML;
use PMLTQ::PML2BASE;
use PMLTQ::Command;
use Module::Load;
use File::Path qw( make_path );

sub run {
  my $self = shift;
  my $config = PMLTQ::Command::load_config(shift);
  my $sqldir = shift;
  my $ext={};
  if(!-d $sqldir) {
    make_path($sqldir) or die "Unable to create directory $sqldir\n";
  }
  Treex::PML::AddResourcePath($config->{resources});
  if(exists $config->{extension}) {
    load "PMLTQ::PML2BASE::".$config->{extension};
    print STDERR "TODO !!! convert\n";
    $ext = { (eval {'$PMLTQ::PML2BASE::'.$config->{extension}."::export"})};
  }
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

    for my $file (glob(File::Spec->catfile($config->{data_dir}, $layer->{data}))) {
      print STDERR "$file\n";
      my $fsfile = Treex::PML::Factory->createDocumentFromFile($file);
      if ($Treex::PML::FSError) {
        die "Error loading file $file: $Treex::PML::FSError ($!)\n";
      }
      PMLTQ::PML2BASE::fs2base($fsfile, $ext);
    }
    PMLTQ::PML2BASE::finish();
    PMLTQ::PML2BASE::destroy();
  }
  return 1;
}

=head1 SYNOPSIS

pmltq convert <treebank_config> <sql_dir>

=head1 DESCRIPTION

Convert from PML to SQL.

=head1 OPTIONS

=head1 PARAMS

=over 5

=item B<treebank_config>

Path to configuration file. If a treebank_config is --, config is readed from STDIN.

Path to output directory. If doesn't exist, directory is created.

=back

=cut

1;
