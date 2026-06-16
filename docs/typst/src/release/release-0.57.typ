#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-57")
= Release 0.57

== Distinct aggregations

The #raw("DISTINCT") argument qualifier for aggregation functions is now fully supported. For example:

#code-block(none, "SELECT country, count(DISTINCT city), count(DISTINCT age)
FROM users
GROUP BY country")

#note[
#link(label("fn-approx-distinct"), raw("approx_distinct")) should be used in preference to this whenever an approximate answer is allowable as it is substantially faster and does not have any limits on the number of distinct items it can process. #raw("COUNT(DISTINCT ...)") must transfer every item over the network and keep each distinct item in memory.
]

== Hadoop 2.x

Use the #raw("hive-hadoop2") connector to read Hive data from Hadoop 2.x. See #link(label("doc-installation-deployment"))[Deploying Trino] for details.

== Amazon S3

All Hive connectors support reading data from #link("http://aws.amazon.com/s3/")[Amazon S3]. This requires two additional catalog properties for the Hive connector to specify your AWS Access Key ID and Secret Access Key:

#code-block("text", "hive.s3.aws-access-key=AKIAIOSFODNN7EXAMPLE
hive.s3.aws-secret-key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY")

== Miscellaneous

- Allow specifying catalog and schema in the #link(label("doc-client-jdbc"))[JDBC driver] URL.
- Implement more functionality in the JDBC driver.
- Allow certain custom #raw("InputFormat")s to work by propagating Hive serialization properties to the #raw("RecordReader").
- Many execution engine performance improvements.
- Fix optimizer performance regression.
- Fix weird #raw("MethodHandle") exception.
