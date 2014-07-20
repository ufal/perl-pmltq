package TestPMLTQ;
use PMLTQ::Common;
use PMLTQ::SQLEvaluator;
use List::Util qw(first);

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
  $fsfile = openFile(shift @$files);
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

sub init_sql_evaluator {
  my $id = shift;
  my $configs = shift;
  $conf = first { $_->{id} eq $id } map $_->value, grep $_->name eq 'dbi', PMLTQ::Common::SeqV($configs);
  return unless $conf;
  my $evaluator = PMLTQ::SQLEvaluator->new(undef,{
        connect => $conf,
        #debug=>$DEBUG,
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


1;