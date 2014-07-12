#!/usr/bin/perl -Ilib -I../lib
# Run this like so: `perl test_query.t'
#   Michal Sedlak <sedlakmichal@gmail.com>     2014/05/07 15:13:00

use Test::More;
use Test::Exception;
plan skip_all => 'set TEST_QUERY to enable this test (developer only!)'
  unless $ENV{TEST_QUERY};

use PMLTQ;
use File::Spec ();
use File::Basename;
use FindBin qw($RealBin);
use lib (#$RealBin.'/../libs/fslib', ### MOŽNÁ ZKUSIT CELÉ ZAKOMENTOVAT
         #'/opt/pmltq/engine/libs/fslib',
	 #$RealBin.'/../libs/pml-base',
	 #$RealBin.'/../libs/pmltq',
	 $RealBin.'/../lib', ## PMLTQ
	 $RealBin.'/libs', ## PMLTQ
	 
#	((do { chomp($ENV{TREDLIB}||=`btred -q --lib`); 1 } && $ENV{TREDLIB} && -d $ENV{TREDLIB}) ? $ENV{TREDLIB} : die "Please set the TREDLIB environment variable to point to tred/tredlib!\n")
	);
use TredMacro;
use PMLTQ::TypeMapper;
use PMLTQ::BtredEvaluator;
  
use Treex::PML;
Treex::PML::UseBackends(qw(Storable PMLBackend PMLTransformBackend));
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
#####################
package main;
use utf8;
use lib (	 $RealBin.'/libs');
use TestPMLTQ;


my $tmp = 0;

$PMLTQ::BtredEvaluator::DEBUG//=0;

# list of available user defined relations (this should be compiled automatically based on tred extensions)
$PMLTQ::user_defined = '\b(?:echild|eparent|a/lex.rf\|a/aux.rf|a/lex.rf|a/aux.rf|coref_gram.rf|coref_text.rf|coref_text|coref_gram|compl)\b';

my $treebanks_dir = File::Spec->catdir($FindBin::RealBin,'treebanks');
opendir my $dh, $treebanks_dir or die "Couldn't open dir '$treebanks_dir': $!";
my @treebanks = grep { !/^\./ and !/\.conf$/  } readdir $dh; # all files except the one beginning with dot and ending with .conf
close $dh;




BEGIN {
  my @resources = (
    File::Spec->catfile(PMLTQ->home, 'resources'), # resources for PML-TQ
    glob(File::Spec->catfile($FindBin::RealBin,'treebanks', '*', 'resources')) # Load required resources for all tested treebanks
  );
  Treex::PML::AddResourcePath(@resources);

#$SIG{__WARN__} = sub { use Devel::StackTrace; print STDERR "--------------------------- STACK @_ \n".Devel::StackTrace->new->as_string."---------------------------\n";  };
#$SIG{__DIE__} = sub { use Devel::StackTrace; print STDERR "--------------------------- STACK @_ \n".Devel::StackTrace->new->as_string."---------------------------\n";  die;};

}


#############



sub runquery {
  my $query = shift;
  my $treebank = shift;
  my $name = shift;
  my @files = @_;  
  my $result="";
  Treex::PML::AddResourcePath(File::Spec->catfile(PMLTQ->home, 'resources'),map {File::Spec->catfile((fileparse($_))[1],'..', 'resources')} @files);

	
  
  
  my $fsfile = TestPMLTQ::openFile(shift @files); ###############################################

  #################################################
  #
  # Compile query and initialize the query enginge
  my $evaluator;
  eval {
    $evaluator = PMLTQ::BtredEvaluator->new($query, {
    fsfile => $fsfile,
    #current_filelist => shift @files ###############################################
    # tree => $fsfile->tree(0), # query only a specific tree
    # no_plan => 1, # do not let the planner rewrite my query
                  # in this case, the query must not be a forest!
    });
  };
  ok($evaluator, "create evaluator ($name) on $treebank");
  unless($@)
  {
    binmode STDOUT, ':utf8';
    # running the query and print results
    if ($evaluator->get_filters()) {
      # query with filters (produces text output)
      ## customize output from the final filter
      $evaluator->init_filters({
        init => sub { 
          #print("-" x 60, " $name\n") 
        },
        process_row => sub { 
          #use warnings;
          #use strict 'refs';
          my ($self,$row)=@_; 
          #print("RESULT: ",join("\t",@$row)."\n");
          $result.=join("\t",@$row)."\n"; },
        finish => sub { 
          #print("-" x 60, "\n"); 
        }
      });
      do {{
        $evaluator->run_filters while $evaluator->find_next_match(); # feed the filter pipe
      }} while (TestPMLTQ::next_file($evaluator,\@files));
      $evaluator->flush_filters; # flush the pipe
    } else {
      # query without a fitlter (just selects nodes)
      do {{
        while ($evaluator->find_next_match()) {
        # get whatever data
        ## named query node:
        # print $evaluator->get_result_node('n')->attr('id')."\n";
        ## the order of columns may be differnt than the order of query nodes
        ## since the query can be rewritten by the planner
        #print join("\t", map $_->attr('id'), @{$evaluator->get_results})."\n";
        $result.=join("\t", map $_->attr('id'), @{$evaluator->get_results})."\n";
        
        }
      }} while (TestPMLTQ::next_file($evaluator,\@files));
    }
  }	
  open my $fh, '<:utf8', File::Spec->catfile($FindBin::RealBin, 'results',$treebank,"$name.res") or die "Can't open result file: $name.res\n";
  local $/=undef;
  my $expected = <$fh>;
  ok($result eq $expected, "query evaluation ($name) on $treebank");
}

################
# TEST GRAMMAR PARSER

my $doc = Treex::PML::Factory->createDocument('queries.pml');
$doc->changeBackend('Treex::PML::Backend::PML');
$doc->changeEncoding('utf-8');
$doc->changeSchemaURL('tree_query_schema.xml');
$doc->changeMetaData('schema', PMLTQ::Common::Schema);
$doc->changeMetaData('pml_root', Treex::PML::Factory->createStructure);

my @files = glob(File::Spec->catfile($FindBin::RealBin, 'queries', '*.tq'));

# @files = glob(File::Spec->catfile($FindBin::RealBin, 'queries', 't-dative*.tq')); ####################################
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
    # PŘÍMO DOTAZ VRAZIT DO EVALUATORU
    my $qfile = $query->get_id();
    my ($layer) = basename($qfile) =~ m/^(.)/;
    my @files = glob(File::Spec->catfile($treebanks_dir, $treebank, 'data', "*.$layer.gz"));
    open my $fh, '<:utf8', $query->get_id() || die "Cannot open query file ".$query->get_id().": $!\n";
    local $/;
    my $string_query = <$fh>;
    
    runquery($string_query,$treebank,basename($qfile),@files);# if $qfile =~ m/$ENV{XXX}/;
  }
}

done_testing();
