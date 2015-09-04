package PMLTQ::Command::verify;
use PMLTQ::Command;

sub run {
  my $self = shift;
  my $config = PMLTQ::Command::load_config(shift);
  eval { $dbh = PMLTQ::Command::db_connect($config)};
  die "Database ".$config->{db}->{name}." does not exist !!!\n" if $@;
  print "Database ".$config->{db}->{name}." exists\n";
  my @tables = map {s/^public\.//;$_} grep {m/^public\./} $dbh->tables();
  print "Database contains ", scalar @tables, " tables\n";
  for my $table (@tables) {
    my $sth = $dbh->prepare("SELECT * FROM $table");
    $sth->execute;
    print "Table $table contains ".$sth->rows." rows\n";
  }
  PMLTQ::Command::db_disconnect($dbh);
}


1;