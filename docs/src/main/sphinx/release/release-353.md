# Release 353 (XXXXXXXX March 2021)

## General

* Fix aliasing of columns in common table expressions. ({issue}`6839`)
* Fix potential incorrect query results for queries containing multiple `<` predicates. ({issue}`6896`)
* Always show `SECURITY` clause in `SHOW CREATE VIEW`. ({issue}`6720`)
* Fix reporting column references for aliased tables. ({issue}`6972`)
* Fail `SHOW COLUMNS` when there are issues with getting information about table columns.
  Previously empty list of columns was returned. ({issue}`6958`)
* Improve parallelism of bucketed tables inserts. Inserts into bucketed tables can now be parallelized
  within task using `task.writer-count` feature config. ({issue}`6924`)
* Extend support for correlated subqueries including `UNNEST`. ({issue}`6326`, {issue}`6925`, {issue}`6951`)

## Server RPM

* Allow configuring process environment variables through `/etc/trino/env.sh`. ({issue}`6635`)

## BigQuery connector

* Allow for case-insensitive identifiers matching via `bigquery.case-insensitive-name-matching` config property. ({issue}`6748`)
* Add support for `CREATE TABLE` and `DROP TABLE` statements. ({issue}`3767`)

## Hive connector

* Fix a failure when `INSERT` writes to a partition created by an earlier `INSERT` statement. ({issue}`6853`)
* Correctly recognize directory objects created by AWS S3 web console. ({issue}`6992`)
* Add support for `current_user()` in Hive defined views. ({issue}`6720`)
* Improve insert parallelism when inserting into partitioned and bucketed tables. ({issue}`6866`)
* Add support for reading and writing column statistics from Glue metastore. ({issue}`6178`)

## Iceberg connector

* Correctly recognize directory objects created by AWS S3 web console. ({issue}`6992`)

## Kafka connector

* Fix `Classloader` related issue seen in Worker for Schema Registry tables. ({issue}`6902`)
* Fix querying of Schema Registry tables with References in their schema. ({issue}`6907`)

## MySQL connector

* Fix failure when reading a `datetime` value with more than 3 decimal digits of the second fraction. ({issue}`6852`)
* Fix incorrect predicate pushdown for `char` and `varchar` column with operators like `!=`, `<`, `<=`, `>` and `>=` due
  different case sensitivity between Trino and MySQL. ({issue}`6753`)

## MemSQL connector

* Fix failure when reading a `datetime` value with more than 3 decimal digits of the second fraction. ({issue}`6852`)
* Fix incorrect predicate pushdown for `char` and `varchar` column with operators like `!=`, `<`, `<=`, `>` and `>=` due
  different case sensitivity between Trino and MemSQL. ({issue}`6753`)

## PostgreSQL connector

* Improve performance of queries with `ORDER BY ... LIMIT` clause, when the computation can be pushed down to the underlying database.
  This can be enabled by setting `topn-pushdown.enabled`. Enabling this feature can currently result in incorrect query results when sorting
  on `char` or `varchar` columns. ({issue}`6847`)

## Phoenix connector

* Add support for Phoenix 5.1. To use connect to Phoenix 5.1 server user `connector.name=phoenix-5` in catalog
  configuration file. ({issue}`6865`)

## Redshift connector

* Fix failure when reading a `timestamp` value with more than 3 decimal digits of the second fraction. ({issue}`6893`)

## SQL Server connector

* Fix incorrect predicate pushdown for `char` and `varchar` column with operators like `!=`, `<`, `<=`, `>` and `>=` due
  different case sensitivity between Trino and SQL Server. ({issue}`6753`)

## SPI

* Fix registering of lazy block listeners when top level block is already loaded.
  Previously such listeners were never called when nested blocks were loaded. ({issue}`6783`)
* Make `LazyBlock#getFullyLoadedBlock` load nested lazy blocks when top level block is already loaded.
  Previously nested lazy blocks were not loaded in such case. ({issue}`6783`)
* Fix `io.trino.connector.ConnectorAwareNodeManager#getWorkerNodes` including
  coordinator when `node-scheduler.include-coordinator` is disabled. ({issue}`7007`)
* The function name passed to `io.trino.spi.connector.ConnectorMetadata#applyAggregation` is now the canonical function name.
  Previously, if query used function alias, the alias name was passed. ({issue}`6189`)
* Extend redirection SPI with support for redirections to
  multiple tables which are unioned together. ({issue}`6679`)
* Change return type of `io.trino.spi.predicate.Range.intersect(Range)`. The method now returns `Optional.empty()`
  instead of throwing when ranges do not overlap. ({issue}`6976`)
* Change signature of `io.trino.spi.connector.ConnectorMetadata.applyJoin`. Method now takes additional `JoinStatistics` argument. ({issue}`7000`)
