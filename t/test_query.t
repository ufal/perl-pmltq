#!/usr/bin/perl -Ilib -I../lib
# Run this like so: `perl test_query.t'
#   Michal Sedlak <sedlakmichal@gmail.com>     2014/05/07 15:13:00

use Test::More;

plan skip_all => 'set TEST_QUERY to enable this test (developer only!)'
  unless $ENV{TEST_QUERY};

use PMLTQ;
use Treex::PML;
use PMLTQ::BtredEvaluator;
use PMLTQ::TypeMapper;
use PMLTQ::Common;
use File::Spec ();
use File::Basename;
use FindBin;

$PMLTQ::BtredEvaluator::DEBUG//=0;

# list of available user defined relations (this should be compiled automatically based on tred extensions)
$PMLTQ::user_defined = '\b(?:echild|eparent|a/lex.rf\|a/aux.rf|a/lex.rf|a/aux.rf|coref_gram.rf|coref_text.rf|coref_text|coref_gram|compl)\b';

my $treebanks_dir = File::Spec->catdir($FindBin::RealBin,'treebanks');
opendir my $dh, $treebanks_dir or die "Couldn't open dir '$treebanks_dir': $!";
my @treebanks = grep { !/^\./ } readdir $dh; # all files except the one beginning with dot
close $dh;

BEGIN {
  my @resources = (
    File::Spec->catfile(PMLTQ->home, 'resources'), # resources for PML-TQ
    glob(File::Spec->catfile($FindBin::RealBin,'treebanks', '*', 'resources')) # Load required resources for all tested treebanks
  );
  print join "\n", @resources;
  Treex::PML::AddResourcePath(@resources);
}

sub init_search {
  my ($query, $filename) = @_;
  open my $fh, '<:utf8', $query->get_id() || die "Cannot open query file ".$query->get_id().": $!\n";
  local $/;
  $query = <$fh>;
print "QUERY: $query\n";  
  print "loading document $filename\n";
  my $fsfile = Treex::PML::Factory->createDocumentFromFile($filename,{backends => TredMacro::Backends()});
  if ($Treex::PML::FSError) {
    die "Error loading file $filename: $Treex::PML::FSError ($!)\n";
  }
  print "document loaded\n";
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
print "DEBUG:",$PMLTQ::BtredEvaluator::DEBUG,"\n";
  return PMLTQ::BtredEvaluator->new($query, {
    #type_mapper => PMLTQ::TypeMapper->new({file=>$filename}),
    fsfile => $fsfile,
    plan => 1,
  });
}







#############x

sub runquery {
my ($evaluator,$file, $opt)  = @_;
#!/usr/bin/env perl
# pmltq_nobtred.pl     pajas@ufal.mff.cuni.cz     2009/06/22 13:09:08
print "####### $file\n";
#####################
# Code to provide stuff required from btred
#####################
use FindBin qw($RealBin);
use lib (#$RealBin.'/../libs/fslib',
         '/opt/pmltq/engine/libs/fslib',
	 #$RealBin.'/../libs/pml-base',
	 #$RealBin.'/../libs/pmltq',
	 $RealBin.'/../lib', ## PMLTQ
	 ((do { chomp($ENV{TREDLIB}||=`btred -q --lib`); 1 } && $ENV{TREDLIB} && -d $ENV{TREDLIB}) ? $ENV{TREDLIB} :
	   die "Please set the TREDLIB environment variable to point to tred/tredlib!\n")
	);

use Treex::PML;
Treex::PML::AddResourcePath((File::Spec->catfile(PMLTQ->home, 'resources'),File::Spec->catfile((fileparse($file))[1],'..', 'resources')));
Treex::PML::UseBackends(qw(Storable PMLBackend PMLTransformBackend));

{
  package TredMacro;
  use TrEd::Basics;
  use TrEd::MacroAPI::Default;
  no warnings qw(redefine);
  sub DetermineNodeType {
    my ($node)=@_;
    Treex::PML::Document->determine_node_type($node);
  }
}

{
  package PML;
  sub Schema {
    &Treex::PML::Document::schema; #    &TrEd::Basics::fileSchema;
  }
  sub GetNodeByID {
    my ($id,$fsfile)=@_;
    my $h = $fsfile->appData('id-hash');
    return $h && $id && $h->{$id};
  }
}

use PMLTQ::TypeMapper;
use PMLTQ::BtredEvaluator;

#####################

package main;
use utf8;

#
# Load query from the STDIN, a file or a string
#

$PMLTQ::BtredEvaluator::DEBUG=$opts{debug} || 0;


# running the query and print results
if ($evaluator->get_filters()) {
  # query with filters (produces text output)

  ## customize output from the final filter
  $evaluator->init_filters({
    init => sub { print("-" x 60, "\n") },
    process_row => sub { my ($self,$row)=@_; print(join("\t",@$row)."\n"); },
    finish => sub { print("-" x 60, "\n"); }
   });
    $evaluator->run_filters while $evaluator->find_next_match(); # feed the filter pipe
  $evaluator->flush_filters; # flush the pipe

} else {
    # query without a fitlter (just selects nodes)
    while ($evaluator->find_next_match()) {
      # get whatever data

      ## named query node:
      # print $evaluator->get_result_node('n')->attr('id')."\n";

      ## the order of columns may be differnt than the order of query nodes
      ## since the query can be rewritten by the planner
      print join("\t", map $_->attr('id'), @{$evaluator->get_results})."\n";
    }
}
#################################
}




# TEST GRAMMAR PARSER

my $doc = Treex::PML::Factory->createDocument('queries.pml');
$doc->changeBackend('Treex::PML::Backend::PML');
$doc->changeEncoding('utf-8');
$doc->changeSchemaURL('tree_query_schema.xml');
$doc->changeMetaData('schema', PMLTQ::Common::Schema);
$doc->changeMetaData('pml_root', Treex::PML::Factory->createStructure);

my @files = glob(File::Spec->catfile($FindBin::RealBin, 'queries', '*.tq'));

for my $file (@files) {
  local $/;
  undef $/;

  open my $fh, '<:utf8', $file or die "Can't open file: '$file'\n";
  my $string = <$fh>;
  my $result = PMLTQ::Common::parse_query($string);

  my $query_name = basename($file);
  $query_name=~s/\.\w+$//;
  ok($result, "parsing query '$query_name'");

  $result->set_attr('id', $file);
  
  $doc->append_tree($result); ## every tree contains one query
}


for my $treebank (@treebanks) {
  
  for my $query ($doc->trees) {
    print "QUERY:\t",$query->get_id(),"\n";
    my $qfile = $query->get_id();
    #map {`export TREDLIB=/opt/tred/tredlib; perl /opt/pmltq/engine/contrib/pmltq_nobtred.pl -f $qfile  $_`} @files;
    #die "Use contrib/pmltq_nobtred.pl to run queries";
    #my $evaluator = init_search($query, );
    my @files = glob(File::Spec->catfile($treebanks_dir, $treebank, 'data', '*a.gz'));
    print join("#\n",@files),"\n";
    for my $file (@files){
    
      next unless $file;
      print "\n",$file,"\n";
      runquery(init_search($query,$file),$file) ;

    }
  }
}

done_testing();








