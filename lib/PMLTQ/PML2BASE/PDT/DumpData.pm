package PMLTQ::PML2BASE::PDT::DumpData;

# ABSTRACT: Dump data for PDT user defined relations

use strict;
use warnings;
use PMLTQ::PML2BASE::PDT::DumpData::adata;
use PMLTQ::PML2BASE::PDT::DumpData::tdata;


sub dump_eparent {
  my ($tree,$hash,$fh)=@_;
  my $name = $tree->type->get_schema->get_root_name;

  PMLTQ::PML2BASE::PDT::DumpData::adata::dump_eparent($tree,$hash,$fh) if $name =~ /^adata/;
  PMLTQ::PML2BASE::PDT::DumpData::tdata::dump_eparent($tree,$hash,$fh) if $name =~ /^tdata/;
}

1;
