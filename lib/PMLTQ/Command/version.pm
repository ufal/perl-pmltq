=head1 SYNOPSIS

  pmltq version

=head1 DESCRIPTION

Print program version.

=head1 OPTIONS

=cut

package PMLTQ::Command::version;

sub run {
  my $self = shift;
  print "VERSION";
}



1;