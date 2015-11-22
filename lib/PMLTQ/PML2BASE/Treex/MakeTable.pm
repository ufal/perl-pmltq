package PMLTQ::PML2BASE::Treex::MakeTable;

# ABSTRACT: Make tables for Treex user defined relations

use strict;
use warnings;

sub mk_extra_tables {
  mk_eparent_table(@_) unless $PMLTQ::PML2BASE::opts{'no-eparents'};
  mk_a_rf_table(@_) unless $PMLTQ::PML2BASE::opts{'no-a-rf'};
}

sub mk_a_rf_table {
  my ($schema,$desc,$fh)=@_;
  my $name = $schema->get_root_name;
  my $table_name = PMLTQ::PML2BASE::rename_type($name);
  unless ($PMLTQ::PML2BASE::opts{'no-schema'}) {
    if ($name =~ /^tdata/) {
      $fh->{'#INIT_SQL'}->print(<<"EOF");
CREATE TABLE "${table_name}__#a_rf" ("#idx" INT, "#value" INT);
CREATE INDEX "#Ui_${table_name}_a_rf0" ON "${table_name}__#a_rf" ("#idx");
CREATE INDEX "#Ui_${table_name}_a_rf1" ON "${table_name}__#a_rf" ("#value");
INSERT INTO "#PML_USR_REL" VALUES('a/lex.rf|a/aux.rf',NULL,'t-node','a-node','${table_name}__#a_rf');
EOF

      $fh->{'#DELETE_SQL'}->print(<<"EOF");
DROP TABLE "${table_name}__#a_rf";
DELETE FROM "#PML_USR_REL" WHERE "tbl"='${table_name}__#a_rf';
EOF
      $fh->{'#POST_SQL'}->print(<<"EOF");
INSERT INTO "${table_name}__#a_rf"
  SELECT t."#idx" AS "#idx", a."lex" AS "#value"
    FROM "t-node" t JOIN "t-a" a ON a."#idx"=t."a"
  UNION
  SELECT t."#idx" AS "#idx", aux."#value" AS "#value"
    FROM "t-node" t JOIN "t-a" a ON a."#idx"=t."a" JOIN "t-a/aux.rf" aux ON aux."#idx"=a."aux.rf"
  UNION
  SELECT r."#idx" AS "#idx", r."atree" FROM "t-root" r;
EOF
    }
  }
}

sub mk_eparent_table {
  my ($schema,$desc,$fh)=@_;
  my $name = $schema->get_root_name;
  my @tables;
  my $table_name = PMLTQ::PML2BASE::rename_type($name.'__#eparents');
  ## init tables for both tdata and adata because
  ## treex_documents contains all trees in one document
  my $adata_c_table = PMLTQ::PML2BASE::rename_type($name.'__adata#eparents_c');
  my $adata_table = PMLTQ::PML2BASE::rename_type($name.'__adata#eparents');
  my $tdata_table = PMLTQ::PML2BASE::rename_type($name.'__tdata#eparents');
  unless ($PMLTQ::PML2BASE::opts{'no-schema'}) {
    $fh->{'#INIT_SQL'}->print(<<"EOF");
INSERT INTO "#PML_USR_REL" VALUES('eparentC','echildC','a-node','a-node','${adata_c_table}');
INSERT INTO "#PML_USR_REL" VALUES('eparent','echild','a-node','a-node','${adata_table}');
INSERT INTO "#PML_USR_REL" VALUES('eparent','echild','t-node','t-node','${tdata_table}');
EOF
    $fh->{'#DELETE_SQL'}->print(<<"EOF");
DELETE FROM "#PML_USR_REL" WHERE "tbl"='${adata_table}';
DELETE FROM "#PML_USR_REL" WHERE "tbl"='${tdata_table}';
DELETE FROM "#PML_USR_REL" WHERE "tbl"='${adata_c_table}';
EOF
  }

  @tables = ($adata_table, $tdata_table, $adata_c_table);
  for my $table (@tables) {
    $desc->{$table} = {
      table => $table,
      colspec => [
        ['#idx','INT'],
        ['#value','INT'],
      ],
      index => ["#idx","#value"]
    };
    open $fh->{$table},'>',PMLTQ::PML2BASE::get_full_path(PMLTQ::PML2BASE::to_filename($table));
  }
}

1;
