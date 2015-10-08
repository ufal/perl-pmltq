#!/usr/bin/perl -Ilib -I../lib
# Run this like so: `perl pml2base.t'
#   Matyas Kopp <matyas.kopp@gmail.com>     2015/09/19 20:30:00

use strict;
use warnings;

use Test::More;
plan skip_all => 'set TEST_QUERY to enable this test (developer only!)'
  unless $ENV{TEST_QUERY};

use Capture::Tiny ':all';
use PMLTQ;
use PMLTQ::Commands;
use PMLTQ::Command;
use Treex::PML;
use File::Basename;
use File::Spec;
use File::Temp;
use Test::PostgreSQL;

use FindBin qw($RealBin);
use lib ($RealBin.'/../lib', ## PMLTQ
	 $RealBin.'/libs', 
	);
use DBI;
use TestPMLTQ;

BEGIN {
  my @resources = (
    File::Spec->catfile(PMLTQ->shared_dir, 'resources'), # resources for PML-TQ
    glob(File::Spec->catfile($FindBin::RealBin,'treebanks', '*', 'resources')) # Load required resources for all tested treebanks
  );
  Treex::PML::AddResourcePath(@resources);
}

my @cmds = qw/initdb verify help convert delete load man/;
my $conf_file = File::Spec->catfile($FindBin::RealBin, 'treebanks','pdt20_sample_small', 'config.yml');
my $tmpdir = File::Temp->newdir();
my $tmpdirname   = $tmpdir->dirname;


my $psql;

subtest 'command' => \&command;
subtest 'help' => \&help;
subtest 'convert' => \&convert;

start_postgres();
subtest 'initdb' => \&initdb;
subtest 'load' => \&load;
subtest 'query' => \&query;
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
  my $h = capture_merged {eval {PMLTQ::Commands->run("convert",$conf_file,$datadir)}};
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

sub initdb {
  my $h = capture_merged {eval {PMLTQ::Commands->run("initdb",$conf_file)}};
  ok(! $@, "no error");
  print STDERR $@ if $@;
  ok(dbconnectable(PMLTQ::Command::load_config($conf_file)), "Database exists");
}

sub load {
  undef $@;
  my $h = capture_merged {eval {PMLTQ::Commands->run("load",$conf_file,File::Spec->catfile($tmpdirname,"expdata"))}};
  ok(! $@, "load ok");
  print STDERR $@ if $@;

  my $config = PMLTQ::Command::load_config($conf_file);
  my $dbh = DBI->connect("DBI:".$config->{db}->{driver}.":dbname=".$config->{db}->{name}.";host=".$config->{db}->{host}.";port=".$config->{db}->{port}, 
    $config->{db}->{user}, 
    $config->{db}->{password}, 
    { RaiseError => 0, PrintError => 0, mysql_enable_utf8 => 1 });
  for my $layer (@{$config->{layers}}) {
    my $sth = $dbh->prepare(qq(SELECT "schema" FROM "#PML" WHERE "root" = '$layer->{name}'));
    $sth->execute();
    my $ref = $sth->fetchrow_hashref();
    ok($ref && ! $sth->fetchrow_hashref(), "Schema for $layer->{name} is in database");

  }
  

}

sub query {
  my $config = PMLTQ::Command::load_config($conf_file);
  my $evaluator = TestPMLTQ::init_sql_evaluator($config);
  my $treebank = 'pdt20_sample_small';
  for my $query_file (glob(File::Spec->catfile($FindBin::RealBin, 'queries', '*.tq'))) {
    my $name = basename($query_file);
    local $/;
    undef $/;
    open my $fh, '<:utf8', $query_file or die "Can't open file: '$query_file'\n";
    my $query = <$fh>;
    close($fh);
    my $result;
    eval{$result = TestPMLTQ::run_sql_query($query,$query_file,$evaluator)};
    print STDERR $@;
    ok(defined($result)  , "evaluationable ($name) on $treebank");
    my @rows = defined($result) ? @$result : ();
    my $res="";
    $res .= join("\t",@$_)."\n" for (@rows);
    open my $fh2, '<:utf8', File::Spec->catfile($FindBin::RealBin, 'results',$treebank,"$name.res") or die "Can't open result file: ".File::Spec->catfile($FindBin::RealBin, 'results',$treebank,"$name.res")."\n";
    local $/=undef;
    my $expected = <$fh2>;
    close($fh2);
    ok(defined($result) && $res eq $expected, "query evaluation ($name) on $treebank");
  }
  $evaluator->{dbi}->disconnect();
}

sub del {
  undef $@;
  my $h = capture_merged {eval {PMLTQ::Commands->run("delete",$conf_file)}};
  ok(! $@, "delete ok");
  print STDERR $@ if $@;
  ok(! dbconnectable(PMLTQ::Command::load_config($conf_file)), "Database does not exist");
}

sub verify {
  undef $@;
  my $config = PMLTQ::Command::load_config($conf_file);
  ## database does not exist
  my $h = capture_merged {eval {PMLTQ::Commands->run("verify",$conf_file)}};
  like($@,qr/Database .* does not exist/, "verify database does not exist");
  
  ## database is initialized
  capture_merged {PMLTQ::Commands->run("initdb",$conf_file)};
  undef $@;
  $h = capture_merged {eval {PMLTQ::Commands->run("verify",$conf_file)}};
  ok(! $@, "verify database is initialized");
  
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


sub start_postgres {
  my $config = PMLTQ::Command::load_config($conf_file);
  $psql = Test::PostgreSQL->new(
      port => $config->{db}->{port},
      #auto_start => 0,
      #base_dir => $pg_dir, # use dir for subsequent runs to simply skip initialization
    ) or plan skip_all => $Test::PostgreSQL::errstr;
  my $dbh = DBI->connect($psql->dsn,undef, undef, { RaiseError => 0, PrintError => 0, mysql_enable_utf8 => 1 });
  $dbh->do("CREATE ROLE ".$config->{db}->{user}." WITH CREATEDB LOGIN PASSWORD '".$config->{db}->{password}."';");
  $dbh->disconnect();
}
