package PMLTQ::Command;

use ExtUtils::Installed;

sub load_config {
  my $config_file = shift;
  my $data;
  eval {$data = YAML::Tiny->read($config_file)};
  if ($@ && $@ =~ m/YAML_LOAD_ERR/) {
    print STDERR "unable to load config file '$config_file'\n";
  } elsif ($@ && $@ =~ m/YAML_PARSE_ERR/) {
    $@ =~ s/\n.*//g;
    print STDERR "unable to parse config file '$config_file'\n\t$@\n";
  } elsif (! $data) {
    print STDERR "unable to open config file '$config_file'\n";
  }
  exit unless $data;
  $data->[0]->{db}->{driver} ||= 'Pg';
  return $data->[0];
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
  my $sqlfile = File::Spec->catfile($dir,$file);
  my $sql = do {
      open my $fh, '<', $sqlfile or die "Can't open $sqlfile: $!";
      local $/;
      <$fh>
    };
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
    print STDERR "RUNNING SQL FROM $file\n";
    for my $s (split(/;\s*\n/, $sql)) {
      eval {$dbh->do("$s;");};
    }
  }
}

sub module_list {
  my $inst = ExtUtils::Installed->new();
  my @modules = grep {m/^PMLTQ.*/} $inst->modules();
  return @modules;
}

1;