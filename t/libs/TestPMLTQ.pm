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
  print STDERR "CONF FILE: $conf_file\n";
  my $cfg_root = Treex::PML::Instance->load({ filename=>$conf_file })->get_root;
  return $cfg_root->{configurations};
}

sub init_sql_evaluator {
  my $id = shift;
  my $configs = shift;
  print STDERR "init db: $id\n";
  $conf = first { $_->{id} eq $id } map $_->value, grep $_->name eq 'dbi', PMLTQ::Common::SeqV($configs);
  my $evaluator = PMLTQ::SQLEvaluator->new(undef,{
        connect => $conf,
        #debug=>$DEBUG,
      });
  print STDERR "connecting\n";
  $evaluator->connect();
  print STDERR "CONNECTED !!!\n";
  return $evaluator;
}

sub run_sql_query {
  my $query = shift;
  my $query_id = shift;
  my $evaluator = shift;
  print STDERR "EVALUATOR: $evaluator\n";
  print STDERR "QUERY: $query\n";
  $evaluator->prepare_query($query,{});
  my $result = $evaluator->run({});
  ## CGI::resp_query pak se volá funkce CGI::search(to se pokaždé připojuje k databázi)
=x
  $evaluator->prepare_query($query,{
      node_limit => $opts{node_limit},
      row_limit => $opts{row_limit},
      select_first => $opts{select_first},
      node_IDs => ($tree_print_service ? 1 : 0),
      no_filters => $opts{no_filters},
      use_cursor => $opts{use_cursor},
      no_distinct => $no_distinct,
      timeout => $opts{timeout},
      debug_sql => $opts{debug},
    }); 
  $result = $evaluator->run({
      node_limit => $opts{node_limit},
      row_limit => $opts{row_limit},
      timeout => $opts{timeout},
      use_cursor => $opts{use_cursor},
      return_sth=>1,
    });    
=cut 
  return $result; 
}


1;