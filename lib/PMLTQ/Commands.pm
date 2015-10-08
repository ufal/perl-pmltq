package PMLTQ::Commands;

use strict;
use warnings;
use Module::Load;

sub run {
  my ($self,$name,@args) = @_;
  my $module = "PMLTQ::Command::$name";#_command("PMLTQ::Command::$name");
  unless(eval{load $module;1;}) {
    die qq{Unknown command "$name", maybe you need to install it?\n} if split("\n",$@) <= 2;
    die $@;
  }
  return $module->run(@args);
}

1;