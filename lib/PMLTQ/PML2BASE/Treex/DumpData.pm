package PMLTQ::PML2BASE::Treex::DumpData;

use strict;
use warnings;
use PMLTQ::Relation::Treex;

sub dump_eparent {
  my ($tree,$hash,$fh)=@_;
  my $name = $tree->type->get_schema->get_root_name;
  my $table_name = PMLTQ::PML2BASE::rename_type($name.'__#eparents');
  my $adata_c_table = PMLTQ::PML2BASE::rename_type($name.'__adata#eparents_c');
  my $adata_table = PMLTQ::PML2BASE::rename_type($name.'__adata#eparents');
  my $tdata_table = PMLTQ::PML2BASE::rename_type($name.'__tdata#eparents');
  my $struct_name = $tree->type->get_structure_name||'';
  if ($struct_name eq 'a-root') {
    foreach my $anode ($tree->descendants) {
      foreach my $p (PMLTQ::Relation::Treex::AGetEParentsC($anode)) {
        $fh->{$adata_c_table}->print(PMLTQ::PML2BASE::mkdump($hash->{$anode}{'#idx'}, $hash->{$p}{'#idx'}));
      }
      foreach my $p (PMLTQ::Relation::Treex::AGetEParents($anode)) {
        $fh->{$adata_table}->print(PMLTQ::PML2BASE::mkdump($hash->{$anode}{'#idx'}, $hash->{$p}{'#idx'}));
      }
    }
  } elsif ($struct_name eq 't-root') {
    foreach my $tnode ($tree->descendants) {
      foreach my $p (PMLTQ::Relation::Treex::TGetEParents($tnode)) {
        $fh->{$tdata_table}->print(PMLTQ::PML2BASE::mkdump($hash->{$tnode}{'#idx'}, $hash->{$p}{'#idx'}));
      }
    }
  }
}

1;