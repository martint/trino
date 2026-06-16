#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-115")
= Release 0.115

== General

- Fix an issue with hierarchical queue rules where queries could be rejected after being accepted.
- Add #link(label("fn-sha1"), raw("sha1")), #link(label("fn-sha256"), raw("sha256")) and #link(label("fn-sha512"), raw("sha512")) functions.
- Add #link(label("fn-power"), raw("power")) as an alias for #link(label("fn-pow"), raw("pow")).
- Add support for #raw("LIMIT ALL") syntax.

== Hive

- Fix a race condition which could cause queries to finish without reading all the data.
- Fix a bug in Parquet reader that causes failures while reading lists that has an element schema name other than #raw("array_element") in its Parquet-level schema.
