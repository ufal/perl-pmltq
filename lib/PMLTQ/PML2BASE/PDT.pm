package PMLTQ::PML2BASE::PDT;

use PMLTQ::PML2BASE::PDT::DumpData;
use PMLTQ::PML2BASE::PDT::MakeTable;

our %export=(
    for_each_tree => \&PMLTQ::PML2BASE::PDT::DumpData::dump_eparent,
    for_schema => \&PMLTQ::PML2BASE::PDT::MakeTable::mk_extra_tables
  );

1;