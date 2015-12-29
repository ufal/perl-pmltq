package PMLTQ::Command::version;

# ABSTRACT: Print PMLTQ version

use PMLTQ::Base 'PMLTQ::Command';
use PMLTQ;

has usage => sub { shift->extract_usage };

sub run {
  my $self = shift;
  print( ( $PMLTQ::VERSION || 'DEV' ) . "\n" );
}

=head1 SYNOPSIS

  pmltq version

=head1 DESCRIPTION

Print current PMLTQ version.

=head1 OPTIONS

=cut

1;
