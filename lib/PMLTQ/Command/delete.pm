package PMLTQ::Command::delete;
use PMLTQ::Command;

sub run {
  my $self = shift;
  my $config = PMLTQ::Command::load_config(shift);
  $dbh = PMLTQ::Command::db_connect($config,'postgres');
  $dbh->do("DROP DATABASE ".$config->{db}->{name});
  PMLTQ::Command::db_disconnect($dbh);
}

1;