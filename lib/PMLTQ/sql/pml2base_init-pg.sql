DROP TABLE "#PML";
DROP TABLE "#PMLTYPES";
DROP TABLE "#PMLTABLES";
DROP TABLE "#PML_USR_REL";
CREATE TABLE "#PML" (
  "root" VARCHAR(32) UNIQUE,
  "schema_file" VARCHAR(128) UNIQUE, 
  "data_dir" VARCHAR(128), 
  "schema" TEXT,
  "last_idx" INT,
  "last_node_idx" INT,
  "flags" INT
);
CREATE TABLE "#PMLTYPES" (
  "type" VARCHAR(32) UNIQUE,
  "root" VARCHAR(32)
);
CREATE TABLE "#PMLTABLES" (
  "type" VARCHAR(128) UNIQUE, 
  "table" VARCHAR(32)
);
CREATE TABLE "#PML_USR_REL" (
  "relname" VARCHAR(32) NOT NULL,
  "reverse" VARCHAR(32),
  "node_type" VARCHAR(64),
  "target_node_type" VARCHAR(64),
  "tbl" VARCHAR(32)
);
