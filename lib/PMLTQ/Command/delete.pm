package PMLTQ::Command::delete;

# ABSTRACT: Deletes the treebank from database

use PMLTQ::Base 'PMLTQ::Command';

has usage => sub { shift->extract_usage };

sub run {
  my $self   = shift;
  my $config = $self->config;

  my $dbh = $self->sys_db;
  $dbh->do("DROP DATABASE \"$config->{db}->{name}\";") or die $dbh->errstr;
  $dbh->disconnect;
}

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

1;
