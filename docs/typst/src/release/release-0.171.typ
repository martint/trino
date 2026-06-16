#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-171")
= Release 0.171

== General

- Fix planning regression for queries that compute a mix of distinct and non-distinct aggregations.
- Fix casting from certain complex types to #raw("JSON") when source type contains #raw("JSON") or #raw("DECIMAL").
- Fix issue for data definition queries that prevented firing completion events or purging them from the coordinator's memory.
- Add support for capture in lambda expressions.
- Add support for #raw("ARRAY") and #raw("ROW") type as the compared value in #link(label("fn-min-by"), raw("min_by")) and #link(label("fn-max-by"), raw("max_by")).
- Add support for #raw("CHAR(n)") data type to common string functions.
- Add #link(label("fn-codepoint"), raw("codepoint")), #link(label("fn-skewness"), raw("skewness")) and #link(label("fn-kurtosis"), raw("kurtosis")) functions.
- Improve validation of resource group configuration.
- Fail queries when casting unsupported types to JSON; see #link(label("doc-functions-json"))[JSON functions and operators] for supported types.

== Web UI

- Fix the threads UI \(#raw("/ui/thread")\).

== Hive

- Fix issue where some files are not deleted on cancellation of #raw("INSERT") or #raw("CREATE") queries.
- Allow writing to non-managed \(external\) Hive tables. This is disabled by default but can be enabled via the #raw("hive.non-managed-table-writes-enabled") configuration option.
