#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-122")
= Release 0.122

#warning[
There is a bug in this release that will cause queries to fail when the #raw("optimizer.optimize-hash-generation") config is disabled.
]

== General

- The deprecated casts between JSON and VARCHAR will now fail and provide the user with instructions to migrate their query. For more details, see #link(label("doc-release-release-0-116"))[Release 0.116].
- Fix #raw("NoSuchElementException") when cross join is used inside #raw("IN") query.
- Fix #raw("GROUP BY") to support maps of structural types.
- The web interface now displays a lock icon next to authenticated users.
- The #link(label("fn-min-by"), raw("min_by")) and #link(label("fn-max-by"), raw("max_by")) aggregations now have an additional form that return multiple values.
- Fix incorrect results when using #raw("IN") lists of more than 1000 elements of #raw("timestamp with time zone"), #raw("time with time zone") or structural types.
