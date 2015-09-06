=head1 SYNOPSIS

  pmltq help [command]

=head1 DESCRIPTION

Print list of available commands.

=head1 OPTIONS

=over 5

=item B<command>

Print help for <command>.

=back

=cut

package PMLTQ::Command::help;
use PMLTQ::Command;
use Pod::Usage;
use Pod::Find;
use Module::Load;

sub run {
  my $self = shift;
  my $command = shift;
  my $noexit = shift;
  my @modules = PMLTQ::Command::module_list();
  my %commands = map {my $key = $_; $key =~ s/^PMLTQ::Command:://;($key => $_)} @modules;
  if ($command){
    unknown_command($command,\%commands) unless exists $commands{$command};
    load "PMLTQ::Command::$command";
    pod2usage( -verbose => 99, -input => Pod::Find::pod_where({-inc => 1}, $commands{$command}), $noexit ? (-exitval => 'NOEXIT') : () );
  } else {
    print_commands(\%commands);
  }
}

sub unknown_command {
  my $command = shift;
  my $commands = shift
  print STDERR "Unknown command: $command\n\n";
  print_commands($commands);
  die;
}

sub print_commands {
  my $commands = shift;
  print STDERR "Available commands:\n\t",join("\n\t",sort keys %$commands),"\n"; 
}

1;