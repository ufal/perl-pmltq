#!/usr/bin/env perl
# Run this like so: `perl pml2base.t'
#   Matyas Kopp <matyas.kopp@gmail.com>     2015/09/19 20:30:00

use Test::Most;
use File::Spec;
use Cwd;
use File::Basename 'dirname';
use lib dirname(__FILE__);
use lib File::Spec->rel2abs( File::Spec->catdir( dirname(__FILE__), 'lib' ) );

BEGIN {
  require 'test_commands.pl';    # Load subs to test commands
}

use Capture::Tiny ':all';
use PMLTQ;
use PMLTQ::Commands;
use PMLTQ::Command;
use File::Temp;

start_postgres();

my @CMDS = qw/initdb verify convert delete load/;

subtest command => sub {
  lives_ok { PMLTQ::Commands->run('help') } 'help command ok';
  throws_ok {
    PMLTQ::Commands->run('UNKNOWN_COMMAND')
  }
  qr/unknown command/i, 'calling unknown command fails';
};

subtest help => sub {
  for my $c (@CMDS) {
    my @args = ( 'help', $c, 1 );
    my $h = capture_merged {
      lives_ok { PMLTQ::Commands->run(@args) } "calling help for $c command";
    };
    unlike( $h, qr/^$/, "$c help is not empty" );
  }

  my $c = 'UNKNOWN_COMMAND';
  my @args = ( 'help', "$c", 1 );
  throws_ok { PMLTQ::Commands->run(@args) } qr/unknown command/i, "$c help contains warning 'unknown command'";

  my $h = capture_merged {
    lives_ok { PMLTQ::Commands->run('help') } 'calling help without parameters';
  };
  unlike( $h, qr/^$/, 'help is not empty' );
};

my $cwd = getcwd();

for my $treebank ( treebanks() ) {
  my $tmp_dir       = File::Temp->newdir( CLEANUP => 0 );
  my $output_dir    = $tmp_dir->dirname;
  my $treebank_name = $treebank->{name};
  my $config        = $treebank->{config};

  chdir $treebank->{dir};

  # create, convert and load treebank to the database
  verify( $config, $output_dir );

  # test treebank
  test_queries_for($treebank_name);

  # drop treebank
  del($config);
}

chdir $cwd;

TODO: {
  local $TODO = 'm layer with original schema';
  subtest mschama_convert => sub {
    my $treebank_dir =  abs_path(File::Spec->catdir(  dirname(__FILE__),'conversion_test_treebanks', 'mschema_test' ));
    my @oldResourcePaths = Treex::PML::ResourcePaths();
    Treex::PML::SetResourcePaths(File::Spec->catdir( $treebank_dir, 'resources' )); # replace resource path in subtest
    my $dump_dir       = File::Temp->newdir( CLEANUP => 0 );
    my $config = PMLTQ::Commands::_load_config( File::Spec->catdir( $treebank_dir , 'pmltq.yml' ) );
    chdir $treebank_dir;

    lives_ok { PMLTQ::Commands->run( 'convert', "--output_dir=$dump_dir" ) } 'conversion ok';

    my %files = map { $_ => 1 } read_dir $dump_dir;
    my @tree_columns = qw/r lvl chld chord root_idx/;
    my $regexmatch = join("",map {"(?=.*?\"#$_\",)"} @tree_columns);
    my $regexsubt = "(".join("|",map {"$_"} @tree_columns).")";
    for my $filename (sort grep {m/.ctl$/} keys %files) {
      open my $fh, '<', File::Spec->catfile( $dump_dir,$filename);
      my $sql_cmd = <$fh>;
      close $fh;
      if($sql_cmd =~ m/.*$regexmatch.*/){
        my $linepattern = $sql_cmd;
        $linepattern =~ s/^.*?\(//;
        $linepattern =~ s/\) FROM.*?$//;
        $linepattern =~ s/\"#($regexsubt)\"/(?<$1>\\\\N|[^\\t]*?)/g;
        $linepattern =~ s/"[^,"]*?"/[^\\t]*?/g;
        $linepattern =~ s/,/\\t/g;

        my $datafilename = $filename;
        $datafilename =~ s/\.ctl/\.dump/;
        open $fh, '<', File::Spec->catfile( $dump_dir,$datafilename);
        my $linecnt=1;
        my $errmessage;
        DUMP:while(my $line = <$fh>){
          if($line =~ m/^$linepattern$/){
            for my $tc (@tree_columns){
              if($+{$tc} eq '\N'){
                $errmessage = "column $tc should not be null value at line $linecnt of $datafilename.\n\t$sql_cmd\t$line";
                last DUMP;
              }
            }
          }
          $linecnt++;
        }
        close $fh;
        ok(!$errmessage,$errmessage // "No null value in tree columns in $datafilename")
      }
    }
    Treex::PML::SetResourcePaths(@oldResourcePaths);
  };
}


done_testing();


