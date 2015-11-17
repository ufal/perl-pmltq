package PMLTQ::Commands;

use strict;
use warnings;
use PMLTQ::Loader;

sub run {
  my ( $self, $name, @args ) = @_;
  my $module = "PMLTQ::Command::$name";

  die qq{Unknown command "$name", maybe you need to install it?\n} if PMLTQ::Loader->load($module);
  return $module->run(@args);
}

1;
