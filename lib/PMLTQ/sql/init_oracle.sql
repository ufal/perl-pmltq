-- Original ver. : http://www.oracle-base.com/dba/miscellaneous/concat_agg.sql
-- Created by DR Timothy S Hall (based on an a method suggested by Tom Kyte).
--             http://asktom.oracle.com/pls/ask/f?p=4950:8:::::F4950_P8_DISPLAYID:229614022562
-- Modified by  : Petr Pajas to use empty separator
-- Description  : Aggregate function to concatenate strings.
-- Call Syntax  : Incorporate into queries as follows:
--                  COLUMN employees FORMAT A50
--
--                  SELECT deptno, concat_agg(ename || ', ') AS employees
--                  FROM   emp
--                  GROUP BY deptno;
--
--                      DEPTNO EMPLOYEES
--                  ---------- --------------------------------------------------
--                          10 CLARK, KING, MILLER,
--                          20 SMITH, FORD, ADAMS, SCOTT, JONES,
--                          30 ALLEN, BLAKE, MARTIN, TURNER, JAMES, WARD,
--
-- Last Modified: 24-JUL-2008
--
-- Notes (by Petr Pajas):
--
--   - you can add separator by appending to the concatenated string
--   - to get rid of the last separator, you have to rtrim
--   - this function does not work correctly with NVARCHAR2 and simple
--     replacing all VARCHAR2 to NVARCHAR2 does not work (Oracle internal error!)
--     A workaround for this uses brutal methods. Use e.g.:
--       utl_i18n.raw_to_nchar(concat_agg(utl_i18n.string_to_raw( ... )))
--     instead of
--       concat_agg(...)
--
-- -----------------------------------------------------------------------------------
CREATE OR REPLACE TYPE t_concat_agg AS OBJECT
(
  g_string  VARCHAR2(32767),

  STATIC FUNCTION ODCIAggregateInitialize(sctx  IN OUT  t_concat_agg)
    RETURN NUMBER,

  MEMBER FUNCTION ODCIAggregateIterate(self   IN OUT  t_concat_agg,
                                       value  IN      VARCHAR2 )
     RETURN NUMBER,

  MEMBER FUNCTION ODCIAggregateTerminate(self         IN   t_concat_agg,
                                         returnValue  OUT  VARCHAR2,
                                         flags        IN   NUMBER)
    RETURN NUMBER,

  MEMBER FUNCTION ODCIAggregateMerge(self  IN OUT  t_concat_agg,
                                     ctx2  IN      t_concat_agg)
    RETURN NUMBER
);
/
SHOW ERRORS

CREATE OR REPLACE TYPE BODY t_concat_agg IS
  STATIC FUNCTION ODCIAggregateInitialize(sctx  IN OUT  t_concat_agg)
    RETURN NUMBER IS
  BEGIN
    sctx := t_concat_agg('');
    RETURN ODCIConst.Success;
  END;

  MEMBER FUNCTION ODCIAggregateIterate(self   IN OUT  t_concat_agg,
                                       value  IN      VARCHAR2 )
    RETURN NUMBER IS
  BEGIN
    SELF.g_string := CONCAT(self.g_string, value);
    RETURN ODCIConst.Success;
  END;

  MEMBER FUNCTION ODCIAggregateTerminate(self         IN   t_concat_agg,
                                         returnValue  OUT  VARCHAR2,
                                         flags        IN   NUMBER)
    RETURN NUMBER IS
  BEGIN
    returnValue := SELF.g_string;
    RETURN ODCIConst.Success;
  END;

  MEMBER FUNCTION ODCIAggregateMerge(self  IN OUT  t_concat_agg,
                                     ctx2  IN      t_concat_agg)
    RETURN NUMBER IS
  BEGIN
    SELF.g_string := CONCAT(SELF.g_string, ctx2.g_string);
    RETURN ODCIConst.Success;
  END;
END;
/
SHOW ERRORS


CREATE OR REPLACE FUNCTION concat_agg (p_input VARCHAR2)
RETURN VARCHAR2
PARALLEL_ENABLE AGGREGATE USING t_concat_agg;
/
SHOW ERRORS
