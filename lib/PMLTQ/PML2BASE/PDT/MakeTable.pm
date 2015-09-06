package PMLTQ::PML2BASE::PDT::MakeTable;

sub mk_eparent_table {
  my ($schema,$desc,$fh,$node_type)=@_;
  my $name = $schema->get_root_name;
  my @tables;
  my $table_name = PMLTQ::PML2BASE::rename_type($name.'__#eparents');
  @tables = ($table_name);
  unless ($opts{'no-schema'}) {
    my $node_type;
    if ($node_type) {
      my $node_table  = PMLTQ::PML2BASE::rename_type($node_type);
      $fh->{'#INIT_SQL'}->print(<<"EOF");
INSERT INTO "#PML_USR_REL" VALUES('eparent','echild','${node_type}','${node_type}','${table_name}');
EOF
      $fh->{'#DELETE_SQL'}->print(<<"EOF");
DELETE FROM "#PML_USR_REL" WHERE "tbl"='${table_name}';
EOF
    }
  }
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