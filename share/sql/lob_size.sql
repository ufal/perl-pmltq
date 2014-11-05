CREATE OR REPLACE PROCEDURE lob_size (name in varchar2)  IS
    lobd        BLOB;
    length      INTEGER;
BEGIN
    -- get the LOB locator
    SELECT "schema" INTO lobd FROM "#PML"
        WHERE "root"=name;
    length := dbms_lob.getlength(lobd);
    IF length IS NULL THEN
        dbms_output.put_line('LOB is null.');
    ELSE
        dbms_output.put_line('The length is '
            || length);
    END IF;
END;
.
run;
