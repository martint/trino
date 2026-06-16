#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-144-7")
= Release 0.144.7

== General

- Fail queries with non-equi conjuncts in #raw("OUTER JOIN")s, instead of silently dropping such conjuncts from the query and producing incorrect results.
- Add #link(label("fn-cosine-similarity"), raw("cosine_similarity")) function.
