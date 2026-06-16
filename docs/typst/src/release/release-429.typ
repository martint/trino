#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-429")
= Release 429 \(11 Oct 2023\)

== General

- Allow #link(label("doc-sql-show-functions"))[SHOW FUNCTIONS] for a specific schema. \(#issue("19243", "https://github.com/trinodb/trino/issues/19243")\)
- Add security for function listing. \(#issue("19243", "https://github.com/trinodb/trino/issues/19243")\)

== Security

- Stop performing security checks for functions in the #raw("system.builtin") schema. \(#issue("19160", "https://github.com/trinodb/trino/issues/19160")\)
- Remove support for using function kind as a rule in file-based access control. \(#issue("19160", "https://github.com/trinodb/trino/issues/19160")\)

== Web UI

- Log out from a Trino OAuth session when logging out from the Web UI. \(#issue("13060", "https://github.com/trinodb/trino/issues/13060")\)

== Delta Lake connector

- Allow using the #raw("#") and #raw("?") characters in S3 location paths or URLs. \(#issue("19296", "https://github.com/trinodb/trino/issues/19296")\)

== Hive connector

- Add support for changing a column's type from #raw("varchar") to #raw("date"). \(#issue("19201", "https://github.com/trinodb/trino/issues/19201")\)
- Add support for changing a column's type from #raw("decimal") to #raw("tinyint"), #raw("smallint"), #raw("integer"), or #raw("bigint") in partitioned Hive tables. \(#issue("19201", "https://github.com/trinodb/trino/issues/19201")\)
- Improve performance of reading ORC files. \(#issue("19295", "https://github.com/trinodb/trino/issues/19295")\)
- Allow using the #raw("#") and #raw("?") characters in S3 location paths or URLs. \(#issue("19296", "https://github.com/trinodb/trino/issues/19296")\)
- Fix error reading Avro files when a schema has uppercase characters in its name. \(#issue("19249", "https://github.com/trinodb/trino/issues/19249")\)

== Hudi connector

- Allow using the #raw("#") and #raw("?") characters in S3 location paths or URLs. \(#issue("19296", "https://github.com/trinodb/trino/issues/19296")\)

== Iceberg connector

- Add support for specifying timestamp precision as part of #raw("CREATE TABLE AS .. SELECT") statements. \(#issue("13981", "https://github.com/trinodb/trino/issues/13981")\)
- Improve performance of reading ORC files. \(#issue("19295", "https://github.com/trinodb/trino/issues/19295")\)
- Allow using the #raw("#") and #raw("?") characters in S3 location paths or URLs. \(#issue("19296", "https://github.com/trinodb/trino/issues/19296")\)

== MongoDB connector

- Fix mixed case schema names being inaccessible when using custom roles and the #raw("case-insensitive-name-matching") configuration property is enabled. \(#issue("19218", "https://github.com/trinodb/trino/issues/19218")\)

== SPI

- Change function security checks to return a boolean instead of throwing an exception. \(#issue("19160", "https://github.com/trinodb/trino/issues/19160")\)
- Add SQL path field to #raw("ConnectorViewDefinition"), #raw("ConnectorMaterializedViewDefinition"), and #raw("ViewExpression"). \(#issue("19160", "https://github.com/trinodb/trino/issues/19160")\)
