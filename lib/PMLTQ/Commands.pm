package PMLTQ::Commands;
use Module::Load;

sub run {
  my ($self,$name,@args) = @_;
  my $module = "PMLTQ::Command::$name";#_command("PMLTQ::Command::$name");
  die qq{Unknown command "$name", maybe you need to install it?\n} unless eval{load $module;1;};
  #my $command = $module->new();
  $module->run(@args);
}

1;