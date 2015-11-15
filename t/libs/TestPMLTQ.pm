package TestPMLTQ;

use strict;
use warnings;

use PMLTQ::Common;
use PMLTQ::Command;
use Test::PostgreSQL;
use Test::More;
use PMLTQ::SQLEvaluator;
use List::Util qw(first);

my $psql;

#####################################################
# open a data file and related files on lower layers

sub openFile {
  my $filename=shift;
  Treex::PML::AddResourcePath(File::Spec->catfile((File::Basename::fileparse($filename))[1],'..', 'resources'));
  my $fsfile = Treex::PML::Factory->createDocumentFromFile($filename,{backends => TredMacro::Backends()});
  if ($Treex::PML::FSError) {
    die "Error loading file $filename: $Treex::PML::FSError ($!)\n";
  }
  my $requires = $fsfile->metaData('fs-require');
  if ($requires) {
    for my $req (@$requires) {
      my $req_filename = $req->[1]->abs($fsfile->URL);
      my $secondary = $fsfile->appData('ref');
      unless ($secondary) {
	$secondary = {};
	$fsfile->changeAppData('ref',$secondary);
      }
      my $sf = openFile($req_filename,$fsfile);
      $secondary->{$req->[0]}=$sf;
    }
  }
  return $fsfile;
}

# iterate over several files (or maybe several scattered trees)
sub next_file {
  my ($evaluator,$files)=@_;
  return unless @$files;
  my $fsfile = openFile(shift @$files);
  # reusing the evaluator for next file
  my $iter = $evaluator->get_first_iterator;
  $iter->set_file($fsfile);
  $evaluator->reset(); # prepare for next file
  return 1
}


##########################################################
# useful functions for SQLevaluator

sub read_sql_conf {
  my $conf_file = shift; 
  my $cfg_root = Treex::PML::Instance->load({ filename=>$conf_file })->get_root;
  return $cfg_root->{configurations};
}

sub read_yaml_conf {
  my $conf_file = shift; 
  my $config = PMLTQ::Command::load_config($conf_file);
  return $config;
}

# sub init_sql_evaluator {
#   my $id = shift;
#   my $configs = shift;
#   $conf = first { $_->{id} eq $id } map $_->value, grep $_->name eq 'dbi', PMLTQ::Common::SeqV($configs);
#   return unless $conf;
#   my $evaluator = PMLTQ::SQLEvaluator->new(undef,{
#         connect => $conf,
#         #debug=>$DEBUG,
#       });
#   $evaluator->connect();
#   return $evaluator;
#}

sub init_sql_evaluator {
  my $config = shift;
  return unless $config;
  my $evaluator = PMLTQ::SQLEvaluator->new(undef,{
        connect => {
          database => $config->{db}->{name},
          host => $config->{db}->{host},
          port => $config->{db}->{port},
          driver => 'Pg',
          username => $config->{db}->{user},
          password => $config->{db}->{password},
          # TODO ??? sources, abstract, description
        }
      });
  $evaluator->connect();
  return $evaluator;
}

sub run_sql_query {
  my $query = shift;
  my $query_id = shift;
  my $evaluator = shift;
  $evaluator->prepare_query($query,{});
  my $result = $evaluator->run({});
  return $result; 
}


sub start_postgres {
  my $config = read_yaml_conf(shift);
  $psql = Test::PostgreSQL->new(
      port => $config->{db}->{port},
      #auto_start => 0,
      #base_dir => $pg_dir, # use dir for subsequent runs to simply skip initialization
    ) or plan skip_all => $Test::PostgreSQL::errstr;
  my $dbh = DBI->connect($psql->dsn,undef, undef, { RaiseError => 0, PrintError => 0, mysql_enable_utf8 => 1 });
  $dbh->do("CREATE ROLE ".$config->{db}->{user}." WITH CREATEDB LOGIN PASSWORD '".$config->{db}->{password}."';");
  $dbh->disconnect();
}

sub load_database {
  my $config = read_yaml_conf(shift);
  my $dump_file = shift;
  my @cmd = ('pg_restore', '-d', 'postgres', '-h', $config->{db}->{host}, '-p', $config->{db}->{port}, '-U', 'postgres', '--no-acl', '--no-owner', '--create', '-w', $dump_file);
  #say STDERR join(' ', @cmd);
  system(@cmd) == 0 or die "Restoring test database failed: $?";
  my $dbh = DBI->connect("DBI:Pg:dbname=".$config->{db}->{name}.";host=".$config->{db}->{host}.";port=".$config->{db}->{port},'postgres',undef, { RaiseError => 1, PrintError => 1, mysql_enable_utf8 => 1 });
  $dbh->do("GRANT SELECT ON ALL TABLES IN SCHEMA public TO ".$config->{db}->{user}.";" );
  $dbh->disconnect();
}

sub drop_database {
  my $config = read_yaml_conf(shift);
}


1;