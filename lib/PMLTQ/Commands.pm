package PMLTQ::Commands;

# ABSTRACT: PMLTQ command line interface

use PMLTQ::Base -strict;

use Cwd 'getcwd';
use File::Basename 'fileparse';
use File::Spec;
use Getopt::Long ();
use Hash::Merge qw( merge );
use PMLTQ::Loader qw/find_modules load_class/;
use YAML::Tiny;

sub DEFAULT_CONFIG {
  my $base_dir = shift || getcwd();
  return {
    data_dir   => File::Spec->catdir( $base_dir, 'data' ),
    output_dir => File::Spec->catdir( $base_dir, 'sql_dump' ),
    resources  => File::Spec->catdir( $base_dir, 'resources' ),
    db         => {
      driver => 'Pg',
      host   => 'localhost',
      port   => 5432
    } };
}

sub run {
  my ( $self, $name, @args ) = @_;

  if ( $name && $name =~ /^\w+$/ && ( $name ne 'help' || $args[0] ) ) {
    $name = shift @args if my $help = $name eq 'help';

    my $module = "PMLTQ::Command::$name";

    die qq{Unknown command "$name", maybe you need to install it?\n} unless load_class($module);
    die qq{Command doesn't inherit from PMLTQ::Command} unless $module->isa('PMLTQ::Command');

    my $config = _parse_args( \@args );
    my $command = $module->new( config => $config );
    return $help ? $command->help : $command->run(@args);
  }

  print "Available commands:\n\t",
    join( "\n\t", sort map { s/^PMLTQ::Command:://; $_ } find_modules('PMLTQ::Command') ), "\n";
}

sub _parse_args {
  my $p           = Getopt::Long::Parser->new( config => [qw/pass_through permute no_ignore_case no_auto_abbrev/] );
  my $config_file = '';
  my $config      = {};
  my $command_line_config = {};

  $p->getoptionsfromarray(
    @_,
    'c|config=s' => \$config_file,
    '<>'         => sub {
      my $arg = shift;
      my ( $path, $value ) = $arg =~ m/^--([a-z0-9-_]+)=(.*)$/;
      return unless $path;

      my @path = split /-/, $path;
      my $name = pop @path;
      my $ref  = $command_line_config;
      while ( my $part = shift @path ) {
        $ref->{$part} = {} unless defined $ref->{$part};
        $ref = $ref->{$part};
      }
      $ref->{$name} = $value;
    } );

  if ( $config_file ne '--' ) {
    if ($config_file) {
      die "Configuration file '$config_file' does not exists or is not readable" unless -r $config_file;
    }
    else {
      $config_file = File::Spec->catfile( getcwd(), 'pmltq.yml' );
      $config_file = undef unless -r $config_file;
    }
  }

  $config = _load_config($config_file) if $config_file;

  return merge( $command_line_config, merge( $config, DEFAULT_CONFIG ) );
}

sub _load_config {
  my $config_file = shift;
  my $data;
  my $yaml_str;
  if ( $config_file eq '--' ) {
    $yaml_str = do {
      local $/;
      <STDIN>;
    };
    eval { $data = YAML::Tiny->read_string($yaml_str) };
  }
  else {
    eval { $data = YAML::Tiny->read($config_file) };
  }
  if ( $@ && $@ =~ m/YAML_LOAD_ERR/ ) {
    die "Unable to load config file '$config_file'\n";
  }
  elsif ( $@ && $@ =~ m/YAML_PARSE_ERR/ ) {
    $@ =~ s/\n.*//g;
    die "Unable to parse config file '$config_file'\n\t$@\n";
  }
  elsif ( $config_file eq '--' && !$data ) {
    die "Unable to parse config from STDIN:\n$yaml_str\n";
  }
  elsif ( !$data ) {
    die "Unable to open config file '$config_file'\n";
  }

  my $config = $data->[0];

  my $base_dir = $config->{base_dir};
  unless ($base_dir) {
    ( undef, $base_dir, undef ) = fileparse($config_file);
    $base_dir = File::Spec->rel2abs($base_dir);
  }

  for ( grep { $config->{$_} } qw/data_dir resources output_dir/ ) {
    $config->{$_} = File::Spec->rel2abs( $config->{$_}, $base_dir );
  }

  if ( $config->{layers} ) {
    for my $lr ( @{ $config->{layers} } ) {
      next unless exists $lr->{'related-schema'};
      $lr->{'related-schema'}
        = [ map { File::Spec->rel2abs( $_, $config->{resources} ) } @{ $lr->{'related-schema'} } ];
    }
  }

  return merge( $config, DEFAULT_CONFIG($base_dir) );
}

# sub verify_config {
#   my $conf = shift;
#   die "empty config file !!!" unless $conf;
#   die "config not contain db !!!" unless ref($conf) && ref($conf) eq 'HASH'  &&  exists($conf->{db});
#   for my $d (qw/name host port user password/) {
#     die "config not contain db->$d !!!" unless  exists($conf->{db}->{$d});
#   }
#   for my $d (qw/data_dir layers/) {
#     warn "config not contain $d !!!" unless  exists($conf->{$d});
#   }
#   die "layers sould be array !!!" unless exists($conf->{layers}) || ref($conf->{layers}) eq 'ARRAY';
# }

1;
