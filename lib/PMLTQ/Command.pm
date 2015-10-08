package PMLTQ::Command;

use strict;
use warnings;
use YAML::Tiny;
use SQL::SplitStatement;
use DBI;
#use Module::Find 'useall';

sub load_config {
  my $config_file = shift;
  my $data;
  my $yaml_str;
  if($config_file eq '--') {
    $yaml_str = do {
        local $/;
        <STDIN>
      };
    eval {$data = YAML::Tiny->read_string($yaml_str)};
  }
  else {
    eval {$data = YAML::Tiny->read($config_file)};
  }
  if ($@ && $@ =~ m/YAML_LOAD_ERR/) {
    print STDERR "unable to load config file '$config_file'\n";
  } elsif ($@ && $@ =~ m/YAML_PARSE_ERR/) {
    $@ =~ s/\n.*//g;
    print STDERR "unable to parse config file '$config_file'\n\t$@\n";
  } elsif ($config_file eq '--' && ! $data) {
    print STDERR "unable to parse config from STDIN:\n$yaml_str\n";
  } elsif (! $data) {
    print STDERR "unable to open config file '$config_file'\n";
  }
  exit unless $data;
  verify_config($data->[0]);
  $data->[0]->{db}->{driver} ||= 'Pg';
  # fixing paths
  my $base;
  (undef,$base,undef) = File::Spec->splitpath($config_file);
  $data->[0]->{data_dir} = File::Spec->rel2abs( $data->[0]->{data_dir} , $base );
  $data->[0]->{resources} = File::Spec->rel2abs( $data->[0]->{resources} , $base );
  for my $lr (@{$data->[0]->{layers}}) {
    next unless exists $lr->{'related-schema'};
    $lr->{'related-schema'} = [map {File::Spec->rel2abs( $_ , $base )} @{$lr->{'related-schema'}}];
  }
  return $data->[0];
}

sub verify_config {
  my $conf = shift;
  die "empty config file !!!" unless $conf;
  die "config not contain db !!!" unless ref($conf) && ref($conf) eq 'HASH'  &&  exists($conf->{db});
  for my $d (qw/name host port user password/) {
    die "config not contain db->$d !!!" unless  exists($conf->{db}->{$d});
  }
  for my $d (qw/data_dir layers/) {
    warn "config not contain $d !!!" unless  exists($conf->{$d});
  }
  die "layers sould be array !!!" unless exists($conf->{layers}) || ref($conf->{layers}) eq 'ARRAY';
}

sub db_connect {
  my $config = shift;
  my $dbname = shift || $config->{db}->{name};
  die "Database driver ".$config->{db}->{driver}." is not supported !!!\n" unless $config->{db}->{driver} eq 'Pg';
  my $dbh_ = DBI->connect("DBI:".$config->{db}->{driver}.":dbname=$dbname;host=".$config->{db}->{host}.";port=".$config->{db}->{port}, 
    $config->{db}->{user}, 
    $config->{db}->{password}, 
    { RaiseError => 1, PrintError => 1, mysql_enable_utf8 => 1 }) or die "$error_msg{connection}\n$DBI::errstr";
  return $dbh_;
}

sub db_disconnect {
  my $dbh_ = shift;
  $dbh_->disconnect();
}


sub run_sql_from_file {
  my $file = shift;
  my $dir = shift;
  my $dbh = shift;
  my $sqlfile = File::Spec->catfile($dir,$file);
  my $sql = do {
      open my $fh, '<', $sqlfile or die "Can't open $sqlfile: $!";
      local $/;
      <$fh>
    };
  print STDERR "RUNNING SQL FROM $sqlfile\n";
  if($file =~ m/.ctl/ && $sql =~ m/(COPY .*? FROM *?["'].*?["'])/g ) {
    die "more copy commands than one in file is not supported" if @_ > 1;
    $sql =~ s/(COPY .*? FROM) *?["'](.*?)["']/$1 STDIN/;
    my $dump_file = File::Spec->catfile($dir,$2);
    my $data = do {
        open my $fh, '<', "$dump_file" or die "Can't open $dump_file: $!";
        local $/;
        <$fh>
      };
    eval {
      $dbh->do($sql);
      $dbh->pg_putcopydata("$_\n") for (split(/\n/,$data));
      $dbh->pg_putcopyend();
    };
    warn $@ if $@;
  } else {
    my $sql_splitter = SQL::SplitStatement->new(
        keep_terminators      => 1,
        keep_extra_spaces     => 1,
        keep_comments         => 1,
        keep_empty_statements => 1
    );
    my @statements = $sql_splitter->split($sql);
    for my $s (@statements) {
      eval {$dbh->do($s);};
      print STDERR "SQL:\t$s\n" if $@;
    }
  }
}

sub module_list {
  use Module::Find 'findallmod';
  return findallmod "PMLTQ::Command";
}

1;