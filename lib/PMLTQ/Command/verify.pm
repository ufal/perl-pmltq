package PMLTQ::Command::verify;

# ABSTRACT: Check if database exists and that it contains some data

use PMLTQ::Base 'PMLTQ::Command';

has usage => sub { shift->extract_usage };

sub run {
  my $self = shift;

  my $db_name = $self->config->{db}->{name};

  my $dbh;
  eval { $dbh = $self->db };

  die "Database " . $db_name . " does not exist!\n" if $@;
  print "Database " . $db_name . " exists\n";

  my @tables = map { s/^public\.//; $_ } grep {m/^public\./} $dbh->tables();
  print "Database contains ", scalar @tables, " tables\n";
  for my $table (@tables) {
    my $sth = $dbh->prepare("SELECT * FROM $table");
    $sth->execute;
    print "Table $table contains " . $sth->rows . " rows\n";
  }
  my $sth = $dbh->prepare("SELECT pg_encoding_to_char(encoding) FROM pg_database WHERE datname = '$db_name'");
  $sth->execute;
  print STDERR "Encoding: " . $sth->fetch->[0] . "\n";

  $dbh->disconnect;
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
