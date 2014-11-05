
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.3601"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Query engine and query language for trees in PML format",
  "dist_author" => [
    "Petr Pajas <pajas\@ufal.mff.cuni.cz>",
    "Jan \x{160}t\x{11b}p\x{e1}nek <stepanek\@ufal.mff.cuni.cz>",
    "Michal Sedl\x{e1}k <sedlak\@ufal.mff.cuni.cz>"
  ],
  "dist_name" => "PMLTQ",
  "dist_version" => "0.8.3",
  "license" => "perl",
  "module_name" => "PMLTQ",
  "recommends" => {
    "DBD::Oracle" => 0,
    "DBD::Pg" => "v2.19.3",
    "HTTP::Request::AsCGI" => "1.2",
    "HTTP::Server::Simple::CGI" => "0.44",
    "Net::HTTPServer" => "v1.1.1"
  },
  "recursive_test_files" => 1,
  "requires" => {
    "Benchmark" => "1.12",
    "Digest::MD5" => "2.51",
    "File::ShareDir" => "1.102",
    "Graph" => "0.96",
    "Graph::ChuLiuEdmonds" => "0.06",
    "IO::Scalar" => "2.110",
    "JSON" => "2.90",
    "MIME::Types" => "2.04",
    "Sys::SigAction" => "0.21",
    "Time::HiRes" => "1.97",
    "Treex::PML" => "2.17",
    "YAML" => "0.88"
  },
  "script_files" => [
    "script/pml2base",
    "script/pmltq"
  ],
  "share_dir" => {
    "dist" => "share"
  },
  "test_requires" => {
    "File::Spec" => 0,
    "IO::Handle" => 0,
    "IPC::Open3" => 0,
    "Test::Exception" => "0.32",
    "Test::More" => "0.88"
  }
);


my %fallback_build_requires = (
  "File::Spec" => 0,
  "IO::Handle" => 0,
  "IPC::Open3" => 0,
  "Module::Build" => "0.3601",
  "Test::Exception" => "0.32",
  "Test::More" => "0.88"
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  delete $module_build_args{test_requires};
  $module_build_args{build_requires} = \%fallback_build_requires;
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
