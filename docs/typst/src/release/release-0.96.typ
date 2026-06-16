#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-96")
= Release 0.96

== General

- Fix #link(label("fn-try-cast"), raw("try_cast")) for #raw("TIMESTAMP") and other types that need access to session information.
- Fix planner bug that could result in incorrect results for tables containing columns with the same prefix, underscores and numbers.
- #raw("MAP") type is now comparable.
- Fix output buffer leak in #raw("StatementResource.Query").
- Fix leak in #raw("SqlTasks") caused by invalid heartbeats .
- Fix double logging of queries submitted while the queue is full.
- Fixed "running queries" JMX stat.
- Add #raw("distributed_join") session property to enable\/disable distributed joins.

== Hive

- Add support for tables partitioned by #raw("DATE").
