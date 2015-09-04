package PMLTQ::Command::help;
use PMLTQ::Command;

sub run {
  my $self = shift;
  print STDERR PMLTQ::Command::module_list();
}


1;