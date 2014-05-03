--
-- init pgsql/pl used by initializing scripts
--

-- http://timmurphy.org/2011/08/27/create-language-if-it-doesnt-exist-in-postgresql/
CREATE OR REPLACE FUNCTION create_language_plpgsql()
RETURNS BOOLEAN AS $$
    CREATE LANGUAGE plpgsql;
    SELECT TRUE;
$$ LANGUAGE SQL;

SELECT CASE WHEN NOT
    (
        SELECT  TRUE AS exists
        FROM    pg_language
        WHERE   lanname = 'plpgsql'
        UNION
        SELECT  FALSE AS exists
        ORDER BY exists DESC
        LIMIT 1
    )
THEN
    create_language_plpgsql()
ELSE
    FALSE
END AS plpgsql_created;

DROP FUNCTION create_language_plpgsql();

--
-- aggregation function that concatenates fields
--
--
DROP AGGREGATE IF EXISTS concat_agg(text) ;
CREATE AGGREGATE concat_agg(
  basetype    = text,
  sfunc       = textcat,
  stype       = text,
  initcond    = ''
);
