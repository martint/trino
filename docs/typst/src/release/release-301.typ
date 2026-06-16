#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-301")
= Release 301 \(31 Jan 2019\)

== General

- Fix reporting of aggregate input data size stats. \(#issue("100", "https://github.com/trinodb/trino/issues/100")\)
- Add support for role management \(see #link(label("doc-sql-create-role"))[CREATE ROLE]\).  Note, using #link(label("doc-sql-set-role"))[SET ROLE] requires an up-to-date client library. \(#issue("90", "https://github.com/trinodb/trino/issues/90")\)
- Add #raw("INVOKER") security mode for #link(label("doc-sql-create-view"))[CREATE VIEW]. \(#issue("30", "https://github.com/trinodb/trino/issues/30")\)
- Add #raw("ANALYZE") SQL statement for collecting table statistics. \(#issue("99", "https://github.com/trinodb/trino/issues/99")\)
- Add #link(label("fn-log"), raw("log")) function with arbitrary base. \(#issue("36", "https://github.com/trinodb/trino/issues/36")\)
- Remove the #raw("deprecated.legacy-log-function") configuration option. The legacy behavior \(reverse argument order\) for the #link(label("fn-log"), raw("log")) function is no longer available. \(#issue("36", "https://github.com/trinodb/trino/issues/36")\)
- Remove the #raw("deprecated.legacy-array-agg") configuration option. The legacy behavior \(ignoring nulls\) for #link(label("fn-array-agg"), raw("array_agg")) is no longer available. \(#issue("77", "https://github.com/trinodb/trino/issues/77")\)
- Improve performance of #raw("COALESCE") expressions. \(#issue("35", "https://github.com/trinodb/trino/issues/35")\)
- Improve error message for unsupported #link(label("fn-reduce-agg"), raw("reduce_agg")) state type. \(#issue("55", "https://github.com/trinodb/trino/issues/55")\)
- Improve performance of queries involving #raw("SYSTEM") table sampling and computations over the columns of the sampled table. \(#issue("29", "https://github.com/trinodb/trino/issues/29")\)

== Server RPM

- Do not allow uninstalling RPM while server is still running. \(#issue("67", "https://github.com/trinodb/trino/issues/67")\)

== Security

- Support LDAP with anonymous bind disabled. \(#issue("97", "https://github.com/trinodb/trino/issues/97")\)

== Hive connector

- Add procedure for dumping metastore recording to a file. \(#issue("54", "https://github.com/trinodb/trino/issues/54")\)
- Add Metastore recorder support for Glue. \(#issue("61", "https://github.com/trinodb/trino/issues/61")\)
- Add #raw("hive.temporary-staging-directory-enabled") configuration property and #raw("temporary_staging_directory_enabled") session property to control whether a temporary staging directory should be used for write operations. \(#issue("70", "https://github.com/trinodb/trino/issues/70")\)
- Add #raw("hive.temporary-staging-directory-path") configuration property and #raw("temporary_staging_directory_path") session property to control the location of temporary staging directory that is used for write operations. The #raw("${USER}") placeholder can be used to use a different location for each user \(e.g., #raw("/tmp/${USER}")\). \(#issue("70", "https://github.com/trinodb/trino/issues/70")\)

== Kafka connector

- The minimum supported Kafka broker version is now 0.10.0. \(#issue("53", "https://github.com/trinodb/trino/issues/53")\)

== Base-JDBC connector library

- Add support for defining procedures. \(#issue("73", "https://github.com/trinodb/trino/issues/73")\)
- Add support for providing table statistics. \(#issue("72", "https://github.com/trinodb/trino/issues/72")\)

== SPI

- Include session trace token in #raw("QueryCreatedEvent") and #raw("QueryCompletedEvent"). \(#issue("24", "https://github.com/trinodb/trino/issues/24")\)
- Fix regression in #raw("NodeManager") where node list was not being refreshed on workers.  \(#issue("27", "https://github.com/trinodb/trino/issues/27")\)
