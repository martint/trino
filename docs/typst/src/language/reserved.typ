#import "/lib/trino-docs.typ": *

#anchor("doc-language-reserved")
= Keywords and identifiers

#anchor("ref-language-keywords")

== Reserved keywords

The following table lists all the keywords that are reserved in Trino, along with their status in the SQL standard. These reserved keywords must be quoted \(using double quotes\) in order to be used as an identifier.

#list-table((
  ([Keyword], [SQL:2016], [SQL-92],),
  ([#raw("ALTER")], [reserved], [reserved],),
  ([#raw("AND")], [reserved], [reserved],),
  ([#raw("AS")], [reserved], [reserved],),
  ([#raw("AUTO")], [], [],),
  ([#raw("BETWEEN")], [reserved], [reserved],),
  ([#raw("BY")], [reserved], [reserved],),
  ([#raw("CASE")], [reserved], [reserved],),
  ([#raw("CAST")], [reserved], [reserved],),
  ([#raw("CONSTRAINT")], [reserved], [reserved],),
  ([#raw("CREATE")], [reserved], [reserved],),
  ([#raw("CROSS")], [reserved], [reserved],),
  ([#raw("CUBE")], [reserved], [],),
  ([#raw("CURRENT_CATALOG")], [reserved], [],),
  ([#raw("CURRENT_DATE")], [reserved], [reserved],),
  ([#raw("CURRENT_PATH")], [reserved], [],),
  ([#raw("CURRENT_ROLE")], [reserved], [reserved],),
  ([#raw("CURRENT_SCHEMA")], [reserved], [],),
  ([#raw("CURRENT_TIME")], [reserved], [reserved],),
  ([#raw("CURRENT_TIMESTAMP")], [reserved], [reserved],),
  ([#raw("CURRENT_USER")], [reserved], [],),
  ([#raw("DEALLOCATE")], [reserved], [reserved],),
  ([#raw("DELETE")], [reserved], [reserved],),
  ([#raw("DESCRIBE")], [reserved], [reserved],),
  ([#raw("DISTINCT")], [reserved], [reserved],),
  ([#raw("DROP")], [reserved], [reserved],),
  ([#raw("ELSE")], [reserved], [reserved],),
  ([#raw("END")], [reserved], [reserved],),
  ([#raw("ESCAPE")], [reserved], [reserved],),
  ([#raw("EXCEPT")], [reserved], [reserved],),
  ([#raw("EXISTS")], [reserved], [reserved],),
  ([#raw("EXTRACT")], [reserved], [reserved],),
  ([#raw("FALSE")], [reserved], [reserved],),
  ([#raw("FOR")], [reserved], [reserved],),
  ([#raw("FROM")], [reserved], [reserved],),
  ([#raw("FULL")], [reserved], [reserved],),
  ([#raw("GROUP")], [reserved], [reserved],),
  ([#raw("GROUPING")], [reserved], [],),
  ([#raw("HAVING")], [reserved], [reserved],),
  ([#raw("IN")], [reserved], [reserved],),
  ([#raw("INNER")], [reserved], [reserved],),
  ([#raw("INSERT")], [reserved], [reserved],),
  ([#raw("INTERSECT")], [reserved], [reserved],),
  ([#raw("INTO")], [reserved], [reserved],),
  ([#raw("IS")], [reserved], [reserved],),
  ([#raw("JOIN")], [reserved], [reserved],),
  ([#raw("JSON_ARRAY")], [reserved], [],),
  ([#raw("JSON_EXISTS")], [reserved], [],),
  ([#raw("JSON_OBJECT")], [reserved], [],),
  ([#raw("JSON_QUERY")], [reserved], [],),
  ([#raw("JSON_TABLE")], [reserved], [],),
  ([#raw("JSON_VALUE")], [reserved], [],),
  ([#raw("LEFT")], [reserved], [reserved],),
  ([#raw("LIKE")], [reserved], [reserved],),
  ([#raw("LISTAGG")], [reserved], [],),
  ([#raw("LOCALTIME")], [reserved], [],),
  ([#raw("LOCALTIMESTAMP")], [reserved], [],),
  ([#raw("NATURAL")], [reserved], [reserved],),
  ([#raw("NORMALIZE")], [reserved], [],),
  ([#raw("NOT")], [reserved], [reserved],),
  ([#raw("NULL")], [reserved], [reserved],),
  ([#raw("ON")], [reserved], [reserved],),
  ([#raw("OR")], [reserved], [reserved],),
  ([#raw("ORDER")], [reserved], [reserved],),
  ([#raw("OUTER")], [reserved], [reserved],),
  ([#raw("PREPARE")], [reserved], [reserved],),
  ([#raw("RECURSIVE")], [reserved], [],),
  ([#raw("RIGHT")], [reserved], [reserved],),
  ([#raw("ROLLUP")], [reserved], [],),
  ([#raw("SELECT")], [reserved], [reserved],),
  ([#raw("SKIP")], [reserved], [],),
  ([#raw("TABLE")], [reserved], [reserved],),
  ([#raw("THEN")], [reserved], [reserved],),
  ([#raw("TRIM")], [reserved], [reserved],),
  ([#raw("TRUE")], [reserved], [reserved],),
  ([#raw("UESCAPE")], [reserved], [],),
  ([#raw("UNION")], [reserved], [reserved],),
  ([#raw("UNNEST")], [reserved], [],),
  ([#raw("USING")], [reserved], [reserved],),
  ([#raw("VALUES")], [reserved], [reserved],),
  ([#raw("WHEN")], [reserved], [reserved],),
  ([#raw("WHERE")], [reserved], [reserved],),
  ([#raw("WITH")], [reserved], [reserved],)
), header-rows: 1)

#anchor("ref-language-identifiers")

== Identifiers

Tokens that identify names of catalogs, schemas, tables, columns, functions, or other objects, are identifiers.

Identifiers must start with a letter, and subsequently include alphanumeric characters and underscores. Identifiers with other characters must be delimited with double quotes \(#raw("\"")\). When delimited with double quotes, identifiers can use any character. Escape a #raw("\"") with another preceding double quote in a delimited identifier.

Identifiers are not treated as case sensitive.

Following are some valid examples:

#code-block("sql", "tablename
SchemaName
example_catalog.a_schema.\"table$partitions\"
\"identifierWith\"\"double\"\"quotes\"")

The following identifiers are invalid in Trino and must be quoted when used:

#code-block("text", "table-name
123SchemaName
colum$name@field")
