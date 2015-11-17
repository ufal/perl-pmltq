package PMLTQ::Command::verify;

# ABSTRACT: Check if database exists and that it contains some data

use strict;
use warnings;
use PMLTQ::Command;

sub run {
  my $self = shift;
  my $config = PMLTQ::Command::load_config(shift);
  my $dbh;
  eval { $dbh = PMLTQ::Command::db_connect($config)};
  die "Database ".$config->{db}->{name}." does not exist !!!\n" if $@;
  print "Database ".$config->{db}->{name}." exists\n";
  my @tables = map {s/^public\.//;$_} grep { m/^public\./ } $dbh->tables();
  print "Database contains ", scalar @tables, " tables\n";
  for my $table (@tables) {
    my $sth = $dbh->prepare("SELECT * FROM $table");
    $sth->execute;
    print "Table $table contains ".$sth->rows." rows\n";
  }
  PMLTQ::Command::db_disconnect($dbh);
}

=head1 SYNOPSIS

  pmltq verify <treebank_config>

=head1 DESCRIPTION

Check if database exists and that it contains some data.

=head1 OPTIONS

=head1 PARAMS

=over 5

=item B<treebank_config>

Path to configuration file. If a treebank_config is --, config is readed from STDIN.

=back

=cut

1;
