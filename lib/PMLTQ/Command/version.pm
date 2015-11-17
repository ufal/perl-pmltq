package PMLTQ::Command::version;

# ABSTRACT: Print PMLTQ version

use strict;
use warnings;

use PMLTQ;

sub run {
  my $self = shift;
  print $PMLTQ::VERSION || 'DEV' . "\n";
}

=head1 SYNOPSIS

  pmltq version

=head1 DESCRIPTION

Print program version.

=head1 OPTIONS

=cut

1;
