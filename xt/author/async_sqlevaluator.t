#!/usr/bin/env perl
# Run this like so: `perl async_sqlevaluator.t'
#   Matyas Kopp <matyas.kopp@gmail.com>     2016/03/16 10:56:00

use Test::Most;
use File::Basename 'dirname';
use File::Spec;
use lib File::Spec->rel2abs( File::Spec->catdir( dirname(__FILE__), 'lib' ) );

BEGIN {
  local @ARGV = ("--treebank","pdt_test");
  require 'bootstrap.pl';
}

start_postgres();
init_database();



my ($treebank) = treebanks();
my $query = 'a-node $a:=[] >> for $a.m/lemma give $1,count() >> sort by $1';

my $evaluator = init_sql_evaluator($treebank->{name});
lives_ok { $evaluator->connect() } 'Connection to database successful';
die unless $evaluator->{dbi};

lives_ok {
  $evaluator->prepare_query( $query, { node_IDs => 1, debug_sql => 1 } );
  $evaluator->run( {} );
} 'OK';


done_testing();

sub callback {
  my ($db,$err,$result) = @_;
}
