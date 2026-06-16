#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-179")
= Release 0.179

== General

- Fix issue which could cause incorrect results when processing dictionary encoded data. If the expression can fail on bad input, the results from filtered-out rows containing bad input may be included in the query output \(#issue("8262", "https://github.com/prestodb/presto/issues/8262")\).
- Fix planning failure when similar expressions appear in the #raw("ORDER BY") clause of a query that contains #raw("ORDER BY") and #raw("LIMIT").
- Fix planning failure when #raw("GROUPING()") is used with the #raw("legacy_order_by") session property set to #raw("true").
- Fix parsing failure when #raw("NFD"), #raw("NFC"), #raw("NFKD") or #raw("NFKC") are used as identifiers.
- Fix a memory leak on the coordinator that manifests itself with canceled queries.
- Fix excessive GC overhead caused by captured lambda expressions.
- Reduce the memory usage of map\/array aggregation functions.
- Redact sensitive config property values in the server log.
- Update timezone database to version 2017b.
- Add #link(label("fn-repeat"), raw("repeat")) function.
- Add #link(label("fn-crc32"), raw("crc32")) function.
- Add file based global security, which can be configured with the #raw("etc/access-control.properties") and #raw("security.config-file") config properties. See #link(label("doc-security-built-in-system-access-control"))[System access control] for more details.
- Add support for configuring query runtime and queueing time limits to resource groups.

== Hive

- Fail queries that access encrypted S3 objects that do not have their unencrypted content lengths set in their metadata.

== JDBC driver

- Add support for setting query timeout through #raw("Statement.setQueryTimeout()").

== SPI

- Add grantee and revokee to #raw("GRANT") and #raw("REVOKE") security checks.
