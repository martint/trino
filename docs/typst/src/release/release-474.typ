#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-474")
= Release 474 \(21 Mar 2025\)

#warning[
This release contains a bug in memory tracking that can cause queries to fail with EXCEEDED\_LOCAL\_MEMORY\_LIMIT unnecessarily. See: \(#issue("25600", "https://github.com/trinodb/trino/issues/25600")\)
]

== General

- Add #raw("originalUser") and #raw("authenticatedUser") as resource group selectors. \(#issue("24662", "https://github.com/trinodb/trino/issues/24662")\)
- Fix a correctness bug in #raw("GROUP BY") or #raw("DISTINCT") queries with a large number of unique groups. \(#issue("25381", "https://github.com/trinodb/trino/issues/25381")\)

== Docker image

- Use JDK 24 in the runtime. \(#issue("23501", "https://github.com/trinodb/trino/issues/23501")\)

== Delta Lake connector

- Fix failure for #raw("MERGE") queries on #link("https://delta.io/blog/delta-lake-clone/")[cloned] tables. \(#issue("24756", "https://github.com/trinodb/trino/issues/24756")\)

== Iceberg connector

- Add support for setting session timeout on iceberg REST catalog instances with the Iceberg catalog configuration property #raw("iceberg.rest-catalog.session-timeout"). Defaults to #raw("1h"). \(#issue("25160", "https://github.com/trinodb/trino/issues/25160")\)
- Add support for configuring whether OAuth token refreshes are enabled for Iceberg REST catalogs with theIceberg catalog configugration property #raw("iceberg.rest-catalog.oauth2.token-refresh-enabled"). Defaults to #raw("true"). \(#issue("25160", "https://github.com/trinodb/trino/issues/25160")\)
