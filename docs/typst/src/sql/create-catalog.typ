#import "/lib/trino-docs.typ": *

#anchor("doc-sql-create-catalog")
= CREATE CATALOG

== Synopsis

#code-block("text", "CREATE CATALOG
catalog_name
USING connector_name
[ WITH ( property_name = expression [, ...] ) ]")

== Description

Create a new catalog using the specified connector.

The optional #raw("WITH") clause is used to set properties on the newly created catalog. Property names can be double-quoted, which is required if they contain special characters, like #raw("-"). Refer to the #link(label("doc-connector"))[connectors documentation] to learn about all available properties. All property values must be varchars \(single quoted\), including numbers and boolean values.

The query fails in the following circumstances:

- A required property is missing.
- An invalid property is set, for example there is a typo in the property name, or a property name from a different connector was used.
- The value of the property is invalid, for example a numeric value is out of range, or a string value doesn't match the required pattern.
- The value references an environmental variable that is not set on the coordinator node.

#warning[
The complete #raw("CREATE CATALOG") query is logged, and visible in the #link(label("doc-admin-web-interface"))[Web UI]. This includes any sensitive properties, like passwords and other credentials. See #link(label("doc-security-secrets"))[Secrets].
]

#note[
This command requires the #link(label("doc-admin-properties-catalog"))[catalog management type] to be set to #raw("dynamic").
]

== Examples

Create a new catalog called #raw("tpch") using the #link(label("doc-connector-tpch"))[TPC-H connector]:

#code-block("sql", "CREATE CATALOG tpch USING tpch;")

Create a new catalog called #raw("brain") using the #link(label("doc-connector-memory"))[Memory connector]:

#code-block("sql", "CREATE CATALOG brain USING memory
WITH (\"memory.max-data-per-node\" = '128MB');")

Notice that the connector property contains dashes \(#raw("-")\) and needs to quoted using a double quote \(#raw("\"")\). The value #raw("128MB") is quoted using single quotes, because it is a string literal.

Create a new catalog called #raw("example") using the #link(label("doc-connector-postgresql"))[PostgreSQL connector]:

#code-block("sql", "CREATE CATALOG example USING postgresql
WITH (
  \"connection-url\" = 'jdbc:pg:localhost:5432',
  \"connection-user\" = '${ENV:POSTGRES_USER}',
  \"connection-password\" = '${ENV:POSTGRES_PASSWORD}',
  \"case-insensitive-name-matching\" = 'true'
);")

This example assumes that the #raw("POSTGRES_USER") and #raw("POSTGRES_PASSWORD") environmental variables are set as #link(label("doc-security-secrets"))[secrets] on all nodes of the cluster.

== See also

- #link(label("doc-sql-drop-catalog"))[DROP CATALOG]
- #link(label("doc-admin-properties-catalog"))[Catalog management properties]
