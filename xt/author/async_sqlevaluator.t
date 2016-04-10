#!/usr/bin/env perl
# Run this like so: `perl async_sqlevaluator.t'
#   Matyas Kopp <matyas.kopp@gmail.com>     2016/03/16 10:56:00

use Test::Most;
use File::Basename 'dirname';
use File::Spec;
use lib File::Spec->rel2abs( File::Spec->catdir( dirname(__FILE__), 'lib' ) );

use Mojo::IOLoop;

BEGIN {
  local @ARGV = ("--treebank","pdt_test");
  require 'bootstrap.pl';
}

start_postgres();
init_database();



my ($treebank) = treebanks();

my $query = 'a-node $a:=[] >> for $a.m/lemma give $1,count() >> sort by $1 >> for $1,$2 give $2,$1 >> sort by $1 >> for $1,$2 give $2,$1 >> sort by $1 >> for $1,$2 give $2,$1 >> sort by $1 >> for $1,$2 give $2,$1 ';

my $evaluator = init_sql_evaluator($treebank->{name});
lives_ok { $evaluator->connect() } 'Connection to database successful';
$evaluator->prepare_query( $query, { node_IDs => 1, debug_sql => 1 } );
print STDERR "NUM OF RESULTS: ",scalar @{$evaluator->run( {})};

print STDERR "\n=======================\n";

my ($fail, $result);

my $paralelrun = 10;
my @evals = map {new_connected_prepared_evaluator($treebank->{name},$query,$_,{timeout=>0.1});} (0..$paralelrun);


($fail, $result) = ();

my $delay = Mojo::IOLoop->delay(
  sub {
    my $delay = shift;
    map {$_->run( {cb => $delay->begin})} @evals;
  },
  sub {
    my ($delay, @err_res) = @_;
    $fail = [@err_res[grep {! ($_ & 1)} 1..$#err_res]];
    $result = [map {$_ ? $_->hashes : undef} @err_res[grep {$_ & 1} 1..$#err_res]];
  }
)->catch(sub {
  my ($delay, $err) = @_;
  ok(undef,"ERROR: $err");
});
$delay->wait unless $delay->ioloop->is_running;

use Data::Dumper;
ok(grep {!$_} @$fail, "no error");
ok(!(grep {! $_} @$result), "results ok?");

print STDERR "==========================\n";






my @queries = ();

my $treebank_name = $treebank->{name};
print STDERR "Preparing queries\n";
for my $query ( load_queries($treebank_name) ) {
  my $name = $query->{name};
  my $query_text = $query->{text};
  unless ( $name =~ s/^_// ) {
    my $eval = init_sql_evaluator($treebank_name);
    lives_ok { $eval->connect() } 'Connection to database successful';
    my $tree_query = $eval->prepare_query( $query_text, { node_IDs => 1, debug_sql => 1 } ); 
    push @queries, {
      name=>$name,
      query=>$query_text,
      evaluator => $eval,
      tree_query => $tree_query,
      result => undef,
      fail => undef
    };
  }
}
print STDERR "Querying\n";
$delay = Mojo::IOLoop->delay(
  sub {
    my $delay = shift;
    map {$_->run( {cb => $delay->begin})} @evals;
  },
  sub {
    my ($delay, @err_res) = @_;

    $fail = [@err_res[grep {! ($_ & 1)} 1..$#err_res]];
    $queries[$_]->{fail} = $fail->[$_] for 0..$#queries;
    $result = [map {$_ ? $_->hashes : undef} @err_res[grep {$_ & 1} 1..$#err_res]];
    $queries[$_]->{result} = $result->[$_] for 0..$#queries;
  }
)->catch(sub {
  my ($delay, $err) = @_;
  ok(undef,"ERROR: $err");
});

print STDERR "Waiting\n";
$delay->wait unless $delay->ioloop->is_running;

print STDERR "Testing\n";
for my $qr (@queries) {
  print STDERR $qr->{name},"\n",$qr->{query},"\n";
  subtest "$treebank_name:".$qr->{name} => sub {
    test_results ($qr->{name}, $qr->{treebank_name}, $qr->{evaluator}, $qr->{query}, $qr->{query_tree}, $qr->{result});
  };
}




# ==========================
$evaluator = new_connected_prepared_evaluator($treebank->{name},$query,$_,{timeout=>0.1});

print STDERR "running query:\n";
print STDERR $evaluator->run( {cb => \&callback});



print STDERR "\n\n",Dumper($evaluator->{pg}->db),"\n\n";
done_testing();

sub callback {
  my ($db,$err,$results) = @_;
  print STDERR "callback\n\tDB:$db\n\tERROR:$err\n\tRESULT$results\n";
  $fail = $err;
  $result = $results->hash;

  ok(! $fail, "no error");
  ok($result, "results ok?");

  #Mojo::IOLoop->stop;
}


sub new_connected_prepared_evaluator {
  my ($name,$query,$id,$opts) = @_;
  $opts ||= {};
  my $eval = init_sql_evaluator($name);
  lives_ok { $eval->connect() } 'Connection to database successful';
  $eval->prepare_query( $query, { node_IDs => 1, debug_sql => 1, %{$opts} } ); 
  return $eval;
}

