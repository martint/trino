#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-69")
= Release 0.69

#warning[
The following config properties must be removed from the #raw("etc/config.properties") file on both the coordinator and workers:

- #raw("presto-metastore.db.type")
- #raw("presto-metastore.db.filename")

Additionally, the #raw("datasources") property is now deprecated and should also be removed \(see #link(label("ref-rn-069-datasource-configuration"))[Datasource Configuration]\).
]

== Prevent scheduling work on coordinator

We have a new config property, #raw("node-scheduler.include-coordinator"), that allows or disallows scheduling work on the coordinator. Previously, tasks like final aggregations could be scheduled on the coordinator. For larger clusters, processing work on the coordinator can impact query performance because the machine's resources are not available for the critical task of scheduling, managing and monitoring query execution.

We recommend setting this property to #raw("false") for the coordinator. See #link(label("ref-config-properties"))[config-properties] for an example.

#anchor("ref-rn-069-datasource-configuration")

== Datasource configuration

The #raw("datasources") config property has been deprecated. Please remove it from your #raw("etc/config.properties") file. The datasources configuration is now automatically generated based on the #raw("node-scheduler.include-coordinator") property \(see \[Prevent Scheduling Work on Coordinator\]\).

== Raptor connector

Presto has an extremely experimental connector that was previously called the #raw("native") connector and was intertwined with the main Presto code \(it was written before Presto had connectors\). This connector is now named #raw("raptor") and lives in a separate plugin.

As part of this refactoring, the #raw("presto-metastore.db.type") and #raw("presto-metastore.db.filename") config properties no longer exist and must be removed from #raw("etc/config.properties").

The Raptor connector stores data on the Presto machines in a columnar format using the same layout that Presto uses for in-memory data. Currently, it has major limitations: lack of replication, dropping a table does not reclaim the storage, etc. It is only suitable for experimentation, temporary tables, caching of data from slower connectors, etc. The metadata and data formats are subject to change in incompatible ways between releases.

If you would like to experiment with the connector, create a catalog properties file such as #raw("etc/catalog/raptor.properties") on both the coordinator and workers that contains the following:

#code-block("text", "connector.name=raptor
metadata.db.type=h2
metadata.db.filename=var/data/db/MetaStore")

== Machine learning functions

Presto now has functions to train and use machine learning models \(classifiers and regressors\). This is currently only a proof of concept and is not ready for use in production. Example usage is as follows:

#code-block(none, "SELECT evaluate_classifier_predictions(label, classify(features, model))
FROM (
    SELECT learn_classifier(label, features) AS model
    FROM training_data
)
CROSS JOIN validation_data")

In the above example, the column #raw("label") is a #raw("bigint") and the column #raw("features") is a map of feature identifiers to feature values. The feature identifiers must be integers \(encoded as strings because JSON only supports strings for map keys\) and the feature values are numbers \(floating point\).

== Variable length binary type

Presto now supports the #raw("varbinary") type for variable length binary data. Currently, the only supported function is #link(label("fn-length"), raw("length")). The Hive connector now maps the Hive #raw("BINARY") type to #raw("varbinary").

== General

- Add missing operator: #raw("timestamp with time zone") - #raw("interval year to month")
- Support explaining sampled queries
- Add JMX stats for abandoned and canceled queries
- Add #raw("javax.inject") to parent-first class list for plugins
- Improve error categorization in event logging
