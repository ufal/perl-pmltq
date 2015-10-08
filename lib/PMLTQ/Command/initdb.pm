=head1 SYNOPSIS

  pmltq initdb <treebank_config>
  
=head1 DESCRIPTION

Initialize empty database.

=head1 OPTIONS

=head1 PARAMS

=over 5

=item B<treebank_config>

Path to configuration file. If a treebank_config is --, config is readed from STDIN.

=back

=cut

package PMLTQ::Command::initdb;

use strict;
use warnings;
use PMLTQ;
use PMLTQ::Command;

sub run {
  my $self = shift;
  my $config = PMLTQ::Command::load_config(shift);
  my $dbh = PMLTQ::Command::db_connect($config,'postgres');
  $dbh->do("CREATE DATABASE ".$config->{db}->{name});
  $dbh = PMLTQ::Command::db_connect($config);
  for my $file (qw/init_postgres.sql pml2base_init-pg.sql/) {
    PMLTQ::Command::run_sql_from_file($file,File::Spec->catfile(PMLTQ->shared_dir,"sql"), $dbh);
  }
  PMLTQ::Command::db_disconnect($dbh);
}


1;