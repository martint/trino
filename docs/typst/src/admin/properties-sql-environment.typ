#import "/lib/trino-docs.typ": *

#anchor("doc-admin-properties-sql-environment")
= SQL environment properties

SQL environment properties allow you to globally configure parameters relevant to all SQL queries and the context they are processed in.

== #raw("sql.forced-session-time-zone")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

Force the time zone for any query processing to the configured value, and therefore override the time zone of the client. The time zone must be specified as a string such as #raw("UTC") or #link(label("ref-timestamp-p-with-time-zone-data-type"))[other valid values].

== #raw("sql.default-catalog")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

Set the default catalog for all clients. Any default catalog configuration provided by a client overrides this default.

== #raw("sql.default-schema")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

Set the default schema for all clients. Must be set to a schema name that is valid for the default catalog. Any default schema configuration provided by a client overrides this default.

== #raw("sql.default-function-catalog")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

Set the default catalog for #link(label("doc-udf"))[User-defined functions] storage for all clients. The connector used in the catalog must support #link(label("ref-udf-management"))[SQL statement support]. Any usage of a fully qualified name for a UDF overrides this default.

The default catalog and schema for UDF storage must be configured together, and the resulting entry must be set as part of the path. For example, the following section for #link(label("ref-config-properties"))[Deploying Trino] uses the #raw("functions") schema in the #raw("brain") catalog for UDF storage, and adds it as the only entry on the path:

#code-block("properties", "sql.default-function-catalog=brain
sql.default-function-schema=default
sql.path=brain.default")

== #raw("sql.default-function-schema")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

Set the default schema for UDF storage for all clients. Must be set to a schema name that is valid for the default function catalog. Any usage of a fully qualified name for a UDF overrides this default.

== #raw("sql.path")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

Define the default collection of paths to functions or table functions in specific catalogs and schemas. Paths are specified as #raw("catalog_name.schema_name"). Multiple paths must be separated by commas. Find more details about the path in #link(label("doc-sql-set-path"))[SET PATH].
