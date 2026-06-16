#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-146")
= Release 0.146

== General

- Fix error in #link(label("fn-map-concat"), raw("map_concat")) when the second map is empty.
- Require at least 4096 file descriptors to run Presto.
- Support casting between map types.
- Add #link(label("doc-connector-mongodb"))[MongoDB connector].

== Hive

- Fix incorrect skipping of data in Parquet during predicate push-down.
- Fix reading of Parquet maps and lists containing nulls.
- Fix reading empty ORC file with #raw("hive.orc.use-column-names") enabled.
- Fix writing to S3 when the staging directory is a symlink to a directory.
- Legacy authorization properties, such as #raw("hive.allow-drop-table"), are now only enforced when #raw("hive.security=none") is set, which is the default security system. Specifically, the #raw("sql-standard") authorization system does not enforce these settings.

== Black Hole

- Add support for #raw("varchar(n)").

== Cassandra

- Add support for Cassandra 3.0.
