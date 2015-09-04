package PMLTQ::Command::initdb;
use PMLTQ::Command;

sub run {
  my $self = shift;
  my $config = PMLTQ::Command::load_config(shift);
  $dbh = PMLTQ::Command::db_connect($config,'postgres');
  $dbh->do("CREATE DATABASE ".$config->{db}->{name});
  $dbh = PMLTQ::Command::db_connect($config);
  for my $file (qw/init_postgres.sql pml2base_init-pg.sql/) {
    PMLTQ::Command::run_sql_from_file($file,File::Spec->catfile(PMLTQ->shared_dir,"sql"));
  }
  PMLTQ::Command::db_disconnect($dbh);
}


1;