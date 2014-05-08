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

# list of available user defined relations (this should be compiled automatically based on tred extensions)
$PMLTQ::user_defined = '\b(?:echild|eparent|a/lex.rf\|a/aux.rf|a/lex.rf|a/aux.rf|coref_gram.rf|coref_text.rf|coref_text|coref_gram|compl)\b';

my $treebanks_dir = File::Spec->catdir($FindBin::RealBin,'treebanks');

opendir my $dh, $treebanks_dir or die "Couldn't open dir '$treebanks_dir': $!";
my @treebanks = grep { !/^\./ } readdir $dh; # all files except the one beginning with dot
close $dh;

BEGIN {
  my @resources = (
    File::Spec->catfile(PMLTQ->home, 'resources'), # resources for PML-TQ
    glob(File::Spec->catfile($treebanks_dir, '*', 'resources')) # Load required resources for all tested treebanks
  );
  print join "\n", @resources;
  Treex::PML::AddResourcePath(@resources);
}

sub init_search {
  my ($query, $file) = @_;
  PMLTQ::BtredEvaluator->new($query, {
    type_mapper => PMLTQ::TypeMapper->new({file=>$file}),
    plan => 1,
  });
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
  $doc->append_tree($result);
}


for my $treebank (@treebanks) {
  my @files = glob(File::Spec->catfile($treebanks_dir, $treebank, 'data', '*'));
  
  for my $query ($doc->trees) {
    die "Use contrib/pmltq_nobtred.pl to run queries";
    #my $evaluator = init_search($query, );
  }
}

done_testing();
