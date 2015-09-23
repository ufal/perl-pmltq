#!/usr/bin/perl -Ilib -I../lib
# Run this like so: `perl test_query_sql.t'
#   Matyas Kopp <matyas.kopp@gmail.com>     2015/09/19 20:30:00

use Test::More;
plan skip_all => 'set TEST_QUERY to enable this test (developer only!)'
  unless $ENV{TEST_QUERY};

use Capture::Tiny ':all';
use PMLTQ::Commands;
use File::Basename;
use File::Spec;
use File::Temp;
use FindBin qw($RealBin);
use lib ($RealBin.'/../lib', ## PMLTQ
	 $RealBin.'/libs', 
	);
use DBI;


my @cmds = qw/initdb verify help convert delete load man/;
my $conf_file = File::Spec->catfile($FindBin::RealBin, 'treebanks','pdt20_sample_small', 'config.yml');
my $tmpdir = File::Temp->newdir();
my $tmpdirname   = $tmpdir->dirname;


subtest 'command' => \&command;
subtest 'help' => \&help;
subtest 'convert' => \&convert;
plan skip_all =>  "
SKIPPING THE REST OF TESTS
Run t/scripts/postgres_init.sh under user with postgres CREATEROLE privilege. 
This will create user allowed to create database, that is needed to run the 
rest of tests. After testing you should remove him with t/scripts/postgres_delete.sh
" unless subtest 'test database connection' => \&dbconect;

plan skip_all =>  "
SKIPPING THE REST OF TESTS
Run t/scripts/postgres_delete.sh under user with postgres CREATEROLE privilege. 
And then run t/scripts/postgres_init.sh to reinitialize postgres setting needed 
for testing.
" unless subtest 'test database existence' => \&dbexist;


subtest 'initdb' => \&initdb;
subtest 'load' => \&load;
subtest 'delete' => \&del;
subtest 'verify' => \&verify;


done_testing();

sub command {
  undef $@;
  capture_merged {eval {PMLTQ::Commands->run("help")}};
  ok(! $@, "calling command");
  eval {PMLTQ::Commands->run("UNKNOWN_COMMAND")};
  ok($@, "calling unknown command");
}

sub help {
  for my $c (@cmds) {
    my @args = ("help", $c, 1);
    undef $@;
    my $h = capture_merged {eval {PMLTQ::Commands->run(@args)}};
    ok(! $@, "calling help for $c command");
    isnt($h,'',"$c help is not empty");
  }
  my $c = "UNKNOWN_COMMAND";
  my @args = ("help", "$c", 1);
  undef $@;
  my $h = capture_merged {eval {PMLTQ::Commands->run(@args)}};
  ok($@, "calling help for $c command");
  like($h, qr/unknown command/i,"$c help contains warning 'unknown command'");

  $h = capture_merged {eval {PMLTQ::Commands->run("help")}};
  undef $@;
  ok(! $@, "calling help without parameters");
  isnt($h, '',"help is not empty");
   
}




sub convert {
  my $datadir = File::Spec->catfile($tmpdirname,"expdata");
  my $config = PMLTQ::Command::load_config($conf_file);
  undef $@;
  $h = capture_merged {eval {PMLTQ::Commands->run("convert",$conf_file,$datadir)}};
  ok(! $@, "conversion ok");
  print STDERR $@ if $@;
  my %files =  map {$_ => 1} split(" ",`ls $datadir`);
  for my $layer (@{$config->{layers}}) {
    for my $n (qw/init.sql init.list schema.dump/) {
      my $filename = "$layer->{name}__$n";
      ok(exists $files{$filename} && -s File::Spec->catfile($datadir,$filename),"$filename exists and is not empty");
    }
  }
## TODO absolute/relative paths
## checking conversion (basic)
}


sub dbconect {
  my $config = PMLTQ::Command::load_config($conf_file);
  unless(dbconnectable($config,'postgres')) {
    fail("database connection failed");
    return;
  }
  pass("succesfully connected to database");
  return 1;
}

sub dbexist {
  my $config = PMLTQ::Command::load_config($conf_file);
  if(dbconnectable($config)) {
    fail("database exist");
    return;
  }
  pass("tested database does not exist");
  return 1;
}


sub initdb {
  $h = capture_merged {eval {PMLTQ::Commands->run("initdb",$conf_file)}};
  ok(! $@, "no error");
  print STDERR $@ if $@;
  ok(dbconnectable(PMLTQ::Command::load_config($conf_file)), "Database exists");
}

sub load {
  undef $@;
  $h = capture_merged {eval {PMLTQ::Commands->run("load",$conf_file,File::Spec->catfile($tmpdirname,"expdata"))}};
  ok(! $@, "load ok");
  print STDERR $@ if $@;
}

sub del {
  undef $@;
  $h = capture_merged {eval {PMLTQ::Commands->run("delete",$conf_file)}};
  ok(! $@, "delete ok");
  print STDERR $@ if $@;
  ok(! dbconnectable(PMLTQ::Command::load_config($conf_file)), "Database does not exist");
}

sub verify {
  undef $@;
  my $config = PMLTQ::Command::load_config($conf_file);
  ## database does not exist
  $h = capture_merged {eval {PMLTQ::Commands->run("verify",$conf_file)}};
  like($@,qr/Database .* does not exist/, "verify database does not exist");
  
  ## database is initialized
  capture_merged {PMLTQ::Commands->run("initdb",$conf_file)};
  undef $@;
  $h = capture_merged {eval {PMLTQ::Commands->run("verify",$conf_file)}};
  ok(! $@, "verify database is initialized");
  print STDERR "\n\n##$@\n\n$h\n\n";
  
  like($h,qr/Database $config->{db}->{name} exists/,"database exists");
  like($h,qr/Database contains 4 tables/,"database contains 4 tables");
  
  ## database exists and contains data:
  capture_merged {PMLTQ::Commands->run("load",$conf_file,File::Spec->catfile($tmpdirname,"expdata"))};
  undef $@;
  $h = capture_merged {eval {PMLTQ::Commands->run("verify",$conf_file)}};
  ok(! $@, "verify ok");
  like($h,qr/Database $config->{db}->{name} exists/,"database exists");
  like($h,qr/Database contains [1-9][0-9]*/,"database contains tables");
  like($h,qr/contains [1-9][0-9]* rows/,"database contains nonempty tables");
  capture_merged {PMLTQ::Commands->run("delete",$conf_file)}; # cleaning database
}



sub dbconnectable {
  my $config = shift;
  my $dbname = shift;
  my $dbh = DBI->connect("DBI:".$config->{db}->{driver}.":dbname=".($dbname||$config->{db}->{name}).";host=".$config->{db}->{host}.";port=".$config->{db}->{port}, 
    $config->{db}->{user}, 
    $config->{db}->{password}, 
    { RaiseError => 0, PrintError => 0, mysql_enable_utf8 => 1 });
  return unless $dbh;
  $dbh->disconnect();
  return 1;
}