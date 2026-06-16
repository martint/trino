#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-119")
= Release 0.119

== General

- Add #link(label("doc-connector-redis"))[Redis connector].
- Add #link(label("fn-geometric-mean"), raw("geometric_mean")) function.
- Fix restoring interrupt status in #raw("StatementClient").
- Support getting server version in JDBC driver.
- Improve correctness and compliance of JDBC #raw("DatabaseMetaData").
- Catalog and schema are now optional on the server. This allows connecting and executing metadata commands or queries that use fully qualified names. Previously, the CLI and JDBC driver would use a catalog and schema named #raw("default") if they were not specified.
- Fix scheduler handling of partially canceled queries.
- Execute views with the permissions of the view owner.
- Replaced the #raw("task.http-notification-threads") config option with two independent options: #raw("task.http-response-threads") and #raw("task.http-timeout-threads").
- Improve handling of negated expressions in join criteria.
- Fix #link(label("fn-arbitrary"), raw("arbitrary")), #link(label("fn-max-by"), raw("max_by")) and #link(label("fn-min-by"), raw("min_by")) functions when used with an array, map or row type.
- Fix union coercion when the same constant or column appears more than once on the same side.
- Support #raw("RENAME COLUMN") in #link(label("doc-sql-alter-table"))[ALTER TABLE].

== SPI

- Add more system table distribution modes.
- Add owner to view metadata.

#note[
These are backwards incompatible changes with the previous connector SPI. If you have written a connector, you may need to update your code to the new APIs.
]

== CLI

- Fix handling of full width characters.
- Skip printing query URL if terminal is too narrow.
- Allow performing a partial query cancel using #raw("ctrl-P").
- Allow toggling debug mode during query by pressing #raw("D").
- Fix handling of query abortion after result has been partially received.
- Fix handling of #raw("ctrl-C") when displaying results without a pager.

== Verifier

- Add #raw("expected-double-precision") config to specify the expected level of precision when comparing double values.
- Return non-zero exit code when there are failures.

== Cassandra

- Add support for Cassandra blob types.

== Hive

- Support adding and renaming columns using #link(label("doc-sql-alter-table"))[ALTER TABLE].
- Automatically configure the S3 region when running in EC2.
- Allow configuring multiple Hive metastores for high availability.
- Add support for #raw("TIMESTAMP") and #raw("VARBINARY") in Parquet.

== MySQL and PostgreSQL

- Enable streaming results instead of buffering everything in memory.
- Fix handling of pattern characters when matching table or column names.
