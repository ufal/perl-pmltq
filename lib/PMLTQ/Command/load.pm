=head1 SYNOPSIS

  pmltq load <treebank_config> <sql_dir>

=head1 DESCRIPTION

Load treebank to database

=head1 OPTIONS

=head1 PARAMS

=over 5

=item B<treebank_config>

Path to configuration file. If a treebank_config is --, config is readed from STDIN.

Path to ïnput directory.

=back

=cut

package PMLTQ::Command::load;

use strict;
use warnings;
use PMLTQ::Command;

sub run {
  my $self = shift;
  my $conf = shift;
  my $config = PMLTQ::Command::load_config($conf);
  my $sqldir = shift;
  if(!-d $sqldir) {
    die "Directory $sqldir does not exist\n";
  }
  $dbh = PMLTQ::Command::db_connect($config);
  for my $layer (@{$config->{layers}}) {
    my $listfile = File::Spec->catfile($sqldir,"$layer->{name}__init.list");
    open my $fh, '<', $listfile or die "Can't open $listfile: $!";
    for my $file (<$fh>) {
      $file =~ s/\n$//;
      next unless $file;
      PMLTQ::Command::run_sql_from_file($file,$sqldir,$dbh);
    }
    ###$dbh->do($sql);
  }
  PMLTQ::Command::db_disconnect($dbh);
}


1;