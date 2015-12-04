#!/usr/bin/env perl
# Run this like so: `perl test_query_sql.t'
#   Matyas Kopp <matyas.kopp@gmail.com>     2014/07/12 11:52:00

use Test::Most;
use File::Basename 'dirname';
use File::Spec;
use lib File::Spec->rel2abs( File::Spec->catdir( dirname(__FILE__), 'lib' ) );

plan skip_all => 'Author testing only' unless $ENV{AUTHOR_TESTING};

BEGIN {
  require 'bootstrap.pl';
}

start_postgres();
init_database();

for my $treebank ( treebanks() ) {
  test_queries_for($treebank->{name});
}

done_testing();
