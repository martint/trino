#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-173")
= Release 0.173

== General

- Fix issue where #raw("FILTER") was ignored for #link(label("fn-count"), raw("count")) with a constant argument.
- Support table comments for #link(label("doc-sql-create-table"))[CREATE TABLE] and #link(label("doc-sql-create-table-as"))[CREATE TABLE AS].
