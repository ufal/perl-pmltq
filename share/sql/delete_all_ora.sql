-- delete all tables from the user tablespace
-- creates a temporary file _deleteme.sql in the current directory
SET NEWPAGE 0
SET SPACE 0
SET LINESIZE 80
SET PAGESIZE 0
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING OFF
SET MARKUP HTML OFF
SET ESCAPE \
SPOOL _deleteme.sql
select 'drop table ', '"'||table_name||'"', 'cascade constraints \;' from user_tables;
SPOOL OFF
@_deleteme.sql
