package PMLTQ::PML2BASE::PDT::MakeTable::tdata;
use PMLTQ::PML2BASE::PDT::MakeTable;

sub mk_extra_tables {
  mk_eparent_table(@_) unless $opts{'no-eparents'};
  mk_a_rf_table(@_) unless $opts{'no-a-rf'};
}

sub mk_a_rf_table {
  my ($schema,$desc,$fh)=@_;
  my $name = $schema->get_root_name;
  my $table_name = PMLTQ::PML2BASE::rename_type($name);
  unless ($opts{'no-schema'}) {
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
  PMLTQ::PML2BASE::PDT::MakeTable::mk_eparent_table(@_,'t-node');
}

1;