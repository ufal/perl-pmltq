package PMLTQ::Command::initdb;

# ABSTRACT: Initialize empty database

use PMLTQ::Base 'PMLTQ::Command';
use PMLTQ;

has usage => sub { shift->extract_usage };

sub run {
  my $self = shift;

  my $config = $self->config;
  my $dbh    = $self->sys_db;

  $dbh->do("CREATE DATABASE \"$config->{db}->{name}\";") or die $dbh->errstr;
  $dbh->disconnect;

  $dbh = $self->db;
  for my $file (qw/init_postgres.sql pml2base_init-pg.sql/) {
    $self->run_sql_from_file( $file, File::Spec->catfile( PMLTQ->shared_dir, 'sql' ), $dbh );
  }
  $dbh->disconnect;
}

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

1;
