#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-313")
= Release 313 \(31 May 2019\)

== General

- Fix leak in operator peak memory computations. \(#issue("843", "https://github.com/trinodb/trino/issues/843")\)
- Fix incorrect results for queries involving #raw("GROUPING SETS") and #raw("LIMIT"). \(#issue("864", "https://github.com/trinodb/trino/issues/864")\)
- Add compression and encryption support for #link(label("doc-admin-spill"))[Spill to disk]. \(#issue("778", "https://github.com/trinodb/trino/issues/778")\)

== CLI

- Fix failure when selecting a value of type #link(label("ref-uuid-type"))[uuid-type]. \(#issue("854", "https://github.com/trinodb/trino/issues/854")\)

== JDBC driver

- Fix failure when selecting a value of type #link(label("ref-uuid-type"))[uuid-type]. \(#issue("854", "https://github.com/trinodb/trino/issues/854")\)

== Phoenix connector

- Allow matching schema and table names case insensitively. This can be enabled by setting the #raw("case-insensitive-name-matching") configuration property to true. \(#issue("872", "https://github.com/trinodb/trino/issues/872")\)
