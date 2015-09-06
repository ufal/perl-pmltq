package PMLTQ::PML2BASE::PDT::MakeTable::adata;
use PMLTQ::PML2BASE::PDT::MakeTable;

sub mk_extra_tables {
  mk_eparent_table(@_) unless $opts{'no-eparents'};
}

sub mk_eparent_table {
  PMLTQ::PML2BASE::PDT::MakeTable::mk_eparent_table(@_,'ä-node');
}

1;