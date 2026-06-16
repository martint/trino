#import "/lib/trino-docs.typ": *

#anchor("doc-functions-datasketches")
= DataSketches functions

#link("https://datasketches.apache.org")[Apache DataSketches] is a high-performance library of stochastic streaming algorithms \(sketch algorithms\) that produce compact probabilistic summaries called sketches. A sketch is a small, stateful data structure that processes massive data as a stream and can provide approximate answers with mathematical guarantees much faster than traditional exact methods. DataSketches functions allow querying these serialized sketches from Trino. Support for the #link("https://datasketches.apache.org/docs/Theta/ThetaSketchFramework.html")[Theta Sketch framework] is available through #link(label("fn-theta-sketch-union"), raw("theta_sketch_union")) and #link(label("fn-theta-sketch-cardinality"), raw("theta_sketch_cardinality")), typically used to replace expensive #raw("COUNT(DISTINCT ...)") aggregations when sketches are precomputed and stored.

== Configuration

Because the DataSketches functions are provided by a connector, they are not available by default. To enable them, you must configure a #link(label("ref-catalog-properties"))[catalog properties file] to register the functions with the specified catalog name.

Create a catalog properties file #raw("etc/catalog/datasketches.properties") that references the #raw("datasketches") connector:

#code-block("properties", "connector.name=datasketches")

The DataSketches functions are available with the #raw("theta") schema name. For the preceding example, the functions use the #raw("datasketches.theta") catalog and schema prefix.

To avoid needing to reference the functions with their fully qualified name, configure the #raw("sql.path") #link(label("doc-admin-properties-sql-environment"))[SQL environment property] in the #raw("config.properties") file to include the catalog and schema prefix:

#code-block("properties", "sql.path=datasketches.theta")

Configure multiple catalogs to use the same functions with different DataSketches configurations. In this case, the functions must be referenced using their fully qualified name, rather than relying on the SQL path.

#note[
Trino does not create new sketches. Build Theta sketches upstream \(for example, in Spark, Hive, or Pig using the Apache DataSketches Theta APIs\) and store the serialized sketch bytes as a #raw("VARBINARY") column. The Trino functions operate on serialized Theta sketches only; other sketch families are not supported.
]

== Functions

#function-def("fn-theta-sketch-union", "theta_sketch_union(sketch [, nominal_entries, seed])", "varbinary")[
Returns a serialized sketch as #raw("varbinary"), which is a merged collection of sketches. The optional #raw("nominal_entries") and #raw("seed") parameters let you specify non-default sketch size and seed when merging sketches created with custom settings.
]

#function-def("fn-theta-sketch-cardinality", "theta_sketch_cardinality(sketch)", "double")[
Returns the estimated value of the sketch.
]

#function-def("fn-theta-sketch-cardinality-2", "theta_sketch_cardinality(sketch, seed)", "double", ref: false)[
Returns the estimated value of the sketch using the supplied #raw("seed"). Use this when the sketch was created with a non-default seed.
]

== Examples

The following query reads precomputed customer sketches from #raw("tpch.sf100000.orders"), unions them per order date, and produces an approximate distinct customer count alongside exact spend. Using sketches avoids a heavy #raw("COUNT(DISTINCT ...)") over billions of rows while retaining predictable error bounds.

#code-block("sql", "SELECT
  o_orderdate AS date,
  theta_sketch_cardinality(theta_sketch_union(o_custkey_sketch)) AS unique_user_count,
  SUM(o_totalprice) AS user_spent
FROM tpch.sf100000.orders
GROUP BY o_orderdate;")

For comparison, the exact equivalent requires the raw keys and a costly distinct aggregation:

#code-block("sql", "SELECT
  o_orderdate AS date,
  COUNT(DISTINCT o_custkey) AS unique_user_count,
  SUM(o_totalprice) AS user_spent
FROM tpch.sf100000.orders_raw_keys
GROUP BY o_orderdate;")
