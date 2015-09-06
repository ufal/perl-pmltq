=head1 SYNOPSIS

  pmltq man

=head1 DESCRIPTION

Print whole help.

=cut
package PMLTQ::Command::man;
use PMLTQ::Command;
use PMLTQ::Command::help;

sub run {
  my $self = shift;
  PMLTQ::Command::help->run(undef,1);
  my @modules = PMLTQ::Command::module_list();
  my %commands = map {my $key = $_; $key =~ s/^PMLTQ::Command:://;($key => $_)} @modules;
  for my $cmd (keys %commands){
    print STDERR "\n=== $cmd ===\n";
    PMLTQ::Command::help->run($cmd,1);
  }
}


1;