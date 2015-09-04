package PMLTQ::Command::help;
use PMLTQ::Command;

sub run {
  my $self = shift;
  my @modules = PMLTQ::Command::module_list();
  my @commands = map {s/^PMLTQ::Command:://;$_} @modules;
  print STDERR "Available commands:\n\t",join("\n\t",sort @commands),"\n";
}


1;