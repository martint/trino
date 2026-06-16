#import "/lib/trino-docs.typ": *

#anchor("doc-sql-set-path")
= SET PATH

== Synopsis

#code-block("text", "SET PATH path-element[, ...]")

== Description

Define a collection of paths to functions or table functions in specific catalogs and schemas for the current session.

Each path-element uses a period-separated syntax to specify the catalog name and schema location #raw("<catalog>.<schema>") of the function, or only the schema location #raw("<schema>") in the current catalog. The current catalog is set with use, or as part of a client tool connection. Catalog and schema must exist.

== Examples

The following example sets a path to access functions in the #raw("system") schema of the #raw("example") catalog:

#code-block(none, "SET PATH example.system;")

The catalog uses the PostgreSQL connector, and you can therefore use the #link(label("ref-postgresql-query-function"))[query table function] directly, without the full catalog and schema qualifiers:

#code-block(none, "SELECT
  *
FROM
  TABLE(
    query(
      query => 'SELECT
        *
      FROM
        tpch.nation'
    )
  );")

== See also

- #link(label("doc-sql-use"))[USE]
- #link(label("doc-admin-properties-sql-environment"))[SQL environment properties]
