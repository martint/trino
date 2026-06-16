#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-336")
= Release 336 \(16 Jun 2020\)

== General

- Fix failure when querying timestamp columns from older clients. \(#issue("4036", "https://github.com/trinodb/trino/issues/4036")\)
- Improve reporting of configuration errors. \(#issue("4050", "https://github.com/trinodb/trino/issues/4050")\)
- Fix rare failure when recording server stats in T-Digests. \(#issue("3965", "https://github.com/trinodb/trino/issues/3965")\)

== Security

- Add table access rules to #link(label("doc-security-file-system-access-control"))[File-based access control]. \(#issue("3951", "https://github.com/trinodb/trino/issues/3951")\)
- Add new #raw("default") system access control that allows all operations except user impersonation. \(#issue("4040", "https://github.com/trinodb/trino/issues/4040")\)

== Hive connector

- Fix incorrect query results when reading Parquet files with predicates when #raw("hive.parquet.use-column-names") is set to #raw("false") \(the default\). \(#issue("3574", "https://github.com/trinodb/trino/issues/3574")\)
