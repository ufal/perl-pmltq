=head1 SYNOPSIS

  pmltq version

=head1 DESCRIPTION

Print program version.

=head1 OPTIONS

=cut

package PMLTQ::Command::version;
use strict;
use warnings;

use PMLTQ;

sub run {
  my $self = shift;
  print $PMLTQ::VERSION || 'DEV' . "\n";
}



1;