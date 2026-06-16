#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-110")
= Release 0.110

== General

- Fix result truncation bug in window function #link(label("fn-row-number"), raw("row_number")) when performing a partitioned top-N that chooses the maximum or minimum #raw("N") rows. For example:
  
  #code-block(none, "SELECT * FROM (
      SELECT row_number() OVER (PARTITION BY orderstatus ORDER BY orderdate) AS rn,
          custkey, orderdate, orderstatus
      FROM orders
  ) WHERE rn <= 5;")
