#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-142")
= Release 0.142

== General

- Fix planning bug for #raw("JOIN") criteria that optimizes to a #raw("FALSE") expression.
- Fix planning bug when the output of #raw("UNION") doesn't match the table column order in #raw("INSERT") queries.
- Fix error when #raw("ORDER BY") clause in window specification refers to the same column multiple times.
- Add support for #link(label("ref-complex-grouping-operations"))[complex grouping operations] - #raw("CUBE"), #raw("ROLLUP") and #raw("GROUPING SETS").
- Add support for #raw("IF NOT EXISTS") in #raw("CREATE TABLE AS") queries.
- Add #link(label("fn-substring"), raw("substring")) function.
- Add #raw("http.server.authentication.krb5.keytab") config option to set the location of the Kerberos keytab file explicitly.
- Add #raw("optimize_metadata_queries") session property to enable the metadata-only query optimization.
- Improve support for non-equality predicates in #raw("JOIN") criteria.
- Add support for non-correlated subqueries in aggregation queries.
- Improve performance of #link(label("fn-json-extract"), raw("json_extract")).

== Hive

- Change ORC input format to report actual bytes read as opposed to estimated bytes.
- Fix cache invalidation when renaming tables.
- Fix Parquet reader to handle uppercase column names.
- Fix issue where the #raw("hive.respect-table-format") config option was being ignored.
- Add #link(label("doc-connector-hive"))[hive.compression-codec] config option to control compression used when writing. The default is now #raw("GZIP") for all formats.
- Collect and expose end-to-end execution time JMX metric for requests to AWS services.
