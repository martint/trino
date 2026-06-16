#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-111")
= Release 0.111

== General

- Add #link(label("fn-histogram"), raw("histogram")) function.
- Optimize #raw("CASE") expressions on a constant.
- Add basic support for #raw("IF NOT EXISTS") for #raw("CREATE TABLE").
- Semi-joins are hash-partitioned if #raw("distributed_join") is turned on.
- Add support for partial cast from JSON. For example, #raw("json") can be cast to #raw("array(json)"), #raw("map(varchar, json)"), etc.
- Add implicit coercions for #raw("UNION").
- Expose query stats in the JDBC driver #raw("ResultSet").
