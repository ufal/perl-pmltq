=head1 SYNOPSIS

  pmltq delete <treebank_config>

=head1 DESCRIPTION

Delete the treebank from database.

=head1 OPTIONS

=head1 PARAMS

=over 5

=item B<treebank_config>

Path to configuration file. If a treebank_config is --, config is readed from STDIN.

=back

=cut


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