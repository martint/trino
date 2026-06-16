#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-70")
= Release 0.70

#warning[
This release contained a packaging error that resulted in an unusable server tarball. Do not use this release.
]

== Views

We have added support for creating views within Presto. Views are defined using Presto syntax but are stored \(as blobs\) by connectors. Currently, views are supported by the Raptor and Hive connectors. For the Hive connector, views are stored within the Hive metastore as Hive views, but they cannot be queried by Hive, nor can Hive views be queried by Presto.

See #link(label("doc-sql-create-view"))[CREATE VIEW] and #link(label("doc-sql-drop-view"))[DROP VIEW] for details and examples.

== DUAL table

The synthetic #raw("DUAL") table is no longer supported. As an alternative, please write your queries without a #raw("FROM") clause or use the #raw("VALUES") syntax.

== Presto Verifier

There is a new project, Presto Verifier, which can be used to verify a set of queries against two different clusters.

== Connector improvements

- Connectors can now add hidden columns to a table. Hidden columns are not displayed in #raw("DESCRIBE") or #raw("information_schema"), and are not considered for #raw("SELECT *").  As an example, we have added a hidden #raw("row_number") column to the #raw("tpch") connector.
- Presto contains an extensive test suite to verify the correctness.  This test suite has been extracted into the #raw("presto-test") module for use during connector development. For an example, see #raw("TestRaptorDistributedQueries").

== Machine learning functions

We have added two new machine learning functions, which can be used by advanced users familiar with LIBSVM. The functions are #raw("learn_libsvm_classifier") and #raw("learn_libsvm_regressor"). Both take a parameters string which has the form #raw("key=value,key=value")

== General

- New comparison functions: #link(label("fn-greatest"), raw("greatest")) and #link(label("fn-least"), raw("least"))
- New window functions: #link(label("fn-first-value"), raw("first_value")), #link(label("fn-last-value"), raw("last_value")), and #link(label("fn-nth-value"), raw("nth_value"))
- We have added a config option to disable falling back to the interpreter when expressions fail to be compiled to bytecode. To set this option, add #raw("compiler.interpreter-enabled=false") to #raw("etc/config.properties"). This will force certain queries to fail rather than running slowly.
- #raw("DATE") values are now implicitly coerced to #raw("TIMESTAMP") and #raw("TIMESTAMP WITH TIME ZONE") by setting the hour\/minute\/seconds to #raw("0") with respect to the session timezone.
- Minor performance optimization when planning queries over tables with tens of thousands of partitions or more.
- Fixed a bug when planning #raw("ORDER BY ... LIMIT") queries which could result in duplicate and un-ordered results under rare conditions.
- Reduce the size of stats collected from tasks, which dramatically reduces garbage generation and improves coordinator stability.
- Fix compiler cache for expressions.
- Fix processing of empty or commented out statements in the CLI.

== Hive

- There are two new configuration options for the Hive connector, #raw("hive.max-initial-split-size"), which configures the size of the initial splits, and #raw("hive.max-initial-splits"), which configures the number of initial splits. This can be useful for speeding up small queries, which would otherwise have low parallelism.
- The Hive connector will now consider all tables with a non-empty value for the table property #raw("presto_offline") to be offline. The value of the property will be used in the error message.
- We have added support for #raw("DROP TABLE") in the hive connector. By default, this feature is not enabled.  To enable it, set #raw("hive.allow-drop-table=true") in your Hive catalog properties file.
- Ignore subdirectories when generating splits \(this now matches the non-recursive behavior of Hive\).
- Fix handling of maps with null keys.
