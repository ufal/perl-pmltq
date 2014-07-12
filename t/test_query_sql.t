#!/usr/bin/perl -Ilib -I../lib
# Run this like so: `perl test_query_sql.t'
#   Matyas Kopp <matyas.kopp@gmail.com>     2014/07/12 11:52:00

use Test::More;
plan skip_all => 'set TEST_QUERY to enable this test (developer only!)'
  unless $ENV{TEST_QUERY};

use FindBin qw($RealBin);
use lib ($RealBin.'/../lib', ## PMLTQ
	 $RealBin.'/libs', 
	);
use Treex::PML;
#Treex::PML::UseBackends(qw(Storable PMLBackend PMLTransformBackend));
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
use PMLTQ;
use TestPMLTQ;

BEGIN {
  my @resources = (
    File::Spec->catfile(PMLTQ->home, 'resources'), # resources for PML-TQ
    glob(File::Spec->catfile($FindBin::RealBin,'treebanks', '*', 'resources')) # Load required resources for all tested treebanks
  );
  Treex::PML::AddResourcePath(@resources);

#$SIG{__WARN__} = sub { use Devel::StackTrace; print STDERR "--------------------------- STACK @_ \n".Devel::StackTrace->new->as_string."---------------------------\n";  };
#$SIG{__DIE__} = sub { use Devel::StackTrace; print STDERR "--------------------------- STACK @_ \n".Devel::StackTrace->new->as_string."---------------------------\n";  die;};

}


my $conf_file = File::Spec->catfile($FindBin::RealBin, 'treebanks', 'sql.conf');
my $configs = TestPMLTQ::read_sql_conf($conf_file);
my @treebanks = qw/pdt20_sample_small/;

for my $treebank (@treebanks) {
  print STDERR "TREEBANK: $treebank\n";
  my $evaluator = TestPMLTQ::init_sql_evaluator($treebank,$configs);
  for my $query_file (glob(File::Spec->catfile($FindBin::RealBin, 'queries', '*.tq'))) {
    local $/;
    undef $/;
    open my $fh, '<:utf8', $query_file or die "Can't open file: '$query_file'\n";
    my $query = <$fh>;
    my $result;
    eval{$result = TestPMLTQ::run_sql_query($query,$query_file,$evaluator)};
    my $query_name = basename($query_file);
    ok(defined($result)  , "evaluation ($query_name) on $treebank");
    #use Data::Dumper;$Data::Dumper::Deparse = 1;$Data::Dumper::Maxdepth = 3;print STDERR "RESULT:-----------\n", Dumper $result;
    #print STDERR "@$result";
    print STDERR map {join("\t",@$_)."\n"} @$result;
    <>;
  }
}  



done_testing();
