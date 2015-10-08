package PMLTQ::PML2BASE::PDT::DumpData::adata;

use strict;
use warnings;
use PMLTQ::Relation::PDT;

sub dump_eparent {
  my ($tree,$hash,$fh)=@_;
  my $name = $tree->type->get_schema->get_root_name;
  die "" unless $name =~ /^adata/;
  my $table_name = PMLTQ::PML2BASE::rename_type($name.'__#eparents');
  for my $node ($tree->descendants) {
    for my $p (PMLTQ::Relation::PDT::PML_A::GetEParents($node,\&PMLTQ::Relation::PDT::PML_A::DiveAuxCP)) {
      $fh->{$table_name}->print(PMLTQ::PML2BASE::mkdump($hash->{$node}{'#idx'},$hash->{$p}{'#idx'}));
    }
  }
}

1;