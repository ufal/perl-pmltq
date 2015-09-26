package PMLTQ::PML2BASE::Treex;

use PMLTQ::PML2BASE::Treex::DumpData;
use PMLTQ::PML2BASE::Treex::MakeTable;

our %export=(
    for_each_tree => \&PMLTQ::PML2BASE::Treex::DumpData::dump_eparent,
    for_schema => \&PMLTQ::PML2BASE::Treex::MakeTable::mk_extra_tables
  );

1;