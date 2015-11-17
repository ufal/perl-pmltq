#!/usr/bin/env perl
# Run this like so: `perl test_query_sql.t'
#   Matyas Kopp <matyas.kopp@gmail.com>     2014/07/12 11:52:00

use Test::Most;
use File::Basename qw/dirname basename/;
use File::Slurp;
use Scalar::Util 'blessed';
use lib dirname(__FILE__);

require 'bootstrap.pl';

start_postgres();
init_database();

for my $treebank ( treebanks() ) {
  my $treebank_name = $treebank->{name};
  my $evaluator     = init_sql_evaluator($treebank_name);

  lives_ok { $evaluator->connect() } 'Connection to database successful';
  next unless $evaluator->{dbi};

  for my $query ( load_queries($treebank_name) ) {
    my $name = $query->{name};
    my @args = ( $treebank_name, $evaluator, $query->{text} );

    if ( $name =~ s/^_// ) {
    TODO: {
        local $TODO = 'Failing query...';
        subtest "$treebank_name:$name" => sub {
          sql_test_query( $name, @args );
          fail('Fail');
        }
      }
    }
    else {
      subtest "$treebank_name:$name" => sub {
        sql_test_query( $name, @args );
      }
    }
  }

  undef $evaluator;    # destroy evaluator
}

done_testing();
