#import "/lib/trino-docs.typ": *

#anchor("doc-develop-supporting-merge")
= Supporting #raw("MERGE")

The Trino engine provides APIs to support row-level SQL #raw("MERGE"). To implement #raw("MERGE"), a connector must provide the following:

- An implementation of #raw("ConnectorMergeSink"), which is typically layered on top of a #raw("ConnectorPageSink").
- Methods in #raw("ConnectorMetadata") to get a "rowId" column handle, get the row change paradigm, and to start and complete the #raw("MERGE") operation.

The Trino engine machinery used to implement SQL #raw("MERGE") is also used to support SQL #raw("DELETE") and #raw("UPDATE"). This means that all a connector needs to do is implement support for SQL #raw("MERGE"), and the connector gets all the Data Modification Language \(DML\) operations.

== Standard SQL #raw("MERGE")

Different query engines support varying definitions of SQL #raw("MERGE"). Trino supports the strict SQL specification #raw("ISO/IEC 9075"), published in 2016. As a simple example, given tables #raw("target_table") and #raw("source_table") defined as:

#code-block(none, "CREATE TABLE accounts (
    customer VARCHAR,
    purchases DECIMAL,
    address VARCHAR);
INSERT INTO accounts (customer, purchases, address) VALUES ...;
CREATE TABLE monthly_accounts_update (
    customer VARCHAR,
    purchases DECIMAL,
    address VARCHAR);
INSERT INTO monthly_accounts_update (customer, purchases, address) VALUES ...;")

Here is a possible #raw("MERGE") operation, from #raw("monthly_accounts_update") to #raw("accounts"):

#code-block(none, "MERGE INTO accounts t USING monthly_accounts_update s
    ON (t.customer = s.customer)
    WHEN MATCHED AND s.address = 'Berkeley' THEN
        DELETE
    WHEN MATCHED AND s.customer = 'Joe Shmoe' THEN
        UPDATE SET purchases = purchases + 100.0
    WHEN MATCHED THEN
        UPDATE
            SET purchases = s.purchases + t.purchases, address = s.address
    WHEN NOT MATCHED THEN
        INSERT (customer, purchases, address)
            VALUES (s.customer, s.purchases, s.address);")

SQL #raw("MERGE") tries to match each #raw("WHEN") clause in source order. When a match is found, the corresponding #raw("DELETE"), #raw("INSERT") or #raw("UPDATE") is executed and subsequent #raw("WHEN") clauses are ignored.

SQL #raw("MERGE") supports two operations on the target table and source when a row from the source table or query matches a row in the target table:

- #raw("UPDATE"), in which the columns in the target row are updated.
- #raw("DELETE"), in which the target row is deleted.

In the #raw("NOT MATCHED") case, SQL #raw("MERGE") supports only #raw("INSERT") operations. The values inserted are arbitrary but usually come from the unmatched row of the source table or query.

== #raw("RowChangeParadigm")

Different connectors have different ways of representing row updates, imposed by the underlying storage systems. The  Trino engine classifies these different paradigms as elements of the #raw("RowChangeParadigm") enumeration, returned by enumeration, returned by method #raw("ConnectorMetadata.getRowChangeParadigm(...)").

The #raw("RowChangeParadigm") enumeration values are:

- #raw("CHANGE_ONLY_UPDATED_COLUMNS"), intended for connectors that can update individual columns of rows identified by a #raw("rowId"). The corresponding merge processor class is #raw("ChangeOnlyUpdatedColumnsMergeProcessor").
- #raw("DELETE_ROW_AND_INSERT_ROW"), intended for connectors that represent a row change as a row deletion paired with a row insertion. The corresponding merge processor class is #raw("DeleteAndInsertMergeProcessor").

== Overview of #raw("MERGE") processing

A #raw("MERGE") statement is processed by creating a #raw("RIGHT JOIN") between the target table and the source, on the #raw("MERGE") criteria. The source may be a table or an arbitrary query. For each row in the source table or query, #raw("MERGE") produces a #raw("ROW") object containing:

- the data column values from the #raw("UPDATE") or #raw("INSERT") cases. For the #raw("DELETE") cases, only the partition columns, which determine partitioning and bucketing, are non-null.
- a boolean column containing #raw("true") for source rows that matched some target row, and #raw("false") otherwise.
- an integer that identifies whether the merge case operation is #raw("UPDATE"), #raw("DELETE") or #raw("INSERT"), or a source row for which no case matched. If a source row doesn't match any merge case, all data column values except those that determine distribution are null, and the operation number is -1.

A #raw("SearchedCaseExpression") is constructed from #raw("RIGHT JOIN") result to represent the #raw("WHEN") clauses of the #raw("MERGE"). In the example preceding the #raw("MERGE") is executed as if the #raw("SearchedCaseExpression") were written as:

#code-block(none, "SELECT
 CASE
   WHEN present AND s.address = 'Berkeley' THEN
       -- Null values for delete; present=true; operation DELETE=2, case_number=0
       row(null, null, null, true, 2, 0)
   WHEN present AND s.customer = 'Joe Shmoe' THEN
       -- Update column values; present=true; operation UPDATE=3, case_number=1
       row(t.customer, t.purchases + 100.0, t.address, true, 3, 1)
   WHEN present THEN
       -- Update column values; present=true; operation UPDATE=3, case_number=2
       row(t.customer, s.purchases + t.purchases, s.address, true, 3, 2)
   WHEN (present IS NULL) THEN
       -- Insert column values; present=false; operation INSERT=1, case_number=3
       row(s.customer, s.purchases, s.address, false, 1, 3)
   ELSE
       -- Null values for no case matched; present=false; operation=-1,
       --     case_number=-1
       row(null, null, null, false, -1, -1)
 END
 FROM (SELECT *, true AS present FROM target_table) t
   RIGHT JOIN source_table s ON s.customer = t.customer;")

The Trino engine executes the #raw("RIGHT JOIN") and #raw("CASE") expression, and ensures that no target table row matches more than one source expression row, and ultimately creates a sequence of pages to be routed to the node that runs the #raw("ConnectorMergeSink.storeMergedRows(...)") method.

Like #raw("DELETE") and #raw("UPDATE"), #raw("MERGE") target table rows are identified by a connector-specific #raw("rowId") column handle. For #raw("MERGE"), the #raw("rowId") handle is returned by #raw("ConnectorMetadata.getMergeRowIdColumnHandle(...)").

== #raw("MERGE") redistribution

The Trino #raw("MERGE") implementation allows #raw("UPDATE") to change the values of columns that determine partitioning and\/or bucketing, and so it must "redistribute" rows from the #raw("MERGE") operation to the worker nodes responsible for writing rows with the merged partitioning and\/or bucketing columns.

Since the #raw("MERGE") process in general requires redistribution of merged rows among Trino nodes, the order of rows in pages to be stored are indeterminate. Connectors like Hive that depend on an ascending rowId order for deleted rows must sort the deleted rows before storing them.

To ensure that all inserted rows for a given partition end up on a single node, the redistribution hash on the partition key\/bucket columns is applied to the page partition keys. As a result of the hash, all rows for a specific partition\/bucket hash together, whether they were #raw("MATCHED") rows or #raw("NOT MATCHED") rows.

For connectors whose #raw("RowChangeParadigm") is #raw("DELETE_ROW_AND_INSERT_ROW"), inserted rows are distributed using the layout supplied by #raw("ConnectorMetadata.getInsertLayout()"). For some connectors, the same layout is used for updated rows. Other connectors require a special layout for updated rows, supplied by #raw("ConnectorMetadata.getUpdateLayout()").

=== Connector support for #raw("MERGE")

To start #raw("MERGE") processing, the Trino engine calls:

- #raw("ConnectorMetadata.getMergeRowIdColumnHandle(...)") to get the #raw("rowId") column handle.
- #raw("ConnectorMetadata.getRowChangeParadigm(...)") to get the paradigm supported by the connector for changing existing table rows.
- #raw("ConnectorMetadata.beginMerge(...)") to get the a #raw("ConnectorMergeTableHandle") for the merge operation. That #raw("ConnectorMergeTableHandle") object contains whatever information the connector needs to specify the #raw("MERGE") operation.
- #raw("ConnectorMetadata.getInsertLayout(...)"), from which it extracts the list of partition or table columns that impact write redistribution.
- #raw("ConnectorMetadata.getUpdateLayout(...)"). If that layout is non-empty, it is used to distribute updated rows resulting from the #raw("MERGE") operation.

On nodes that are targets of the hash, the Trino engine calls #raw("ConnectorPageSinkProvider.createMergeSink(...)") to create a #raw("ConnectorMergeSink").

To write out each page of merged rows, the Trino engine calls #raw("ConnectorMergeSink.storeMergedRows(Page)"). The #raw("storeMergedRows(Page)") method iterates over the rows in the page, performing updates and deletes in the #raw("MATCHED") cases, and inserts in the #raw("NOT MATCHED") cases.

When using #raw("RowChangeParadigm.DELETE_ROW_AND_INSERT_ROW"), the engine translates #raw("UPDATE") operations into a pair of #raw("DELETE") and #raw("INSERT") operations before #raw("storeMergedRows(Page)") is called.

To complete the #raw("MERGE") operation, the Trino engine calls #raw("ConnectorMetadata.finishMerge(...)"), passing the table handle and a collection of JSON objects encoded as #raw("Slice") instances. These objects contain connector-specific information specifying what was changed by the #raw("MERGE") operation. Typically this JSON object contains the files written and table and partition statistics generated by the #raw("MERGE") operation. The connector takes appropriate actions, if any.

== #raw("RowChangeProcessor") implementation for #raw("MERGE")

In the #raw("MERGE") implementation, each #raw("RowChangeParadigm") corresponds to an internal Trino engine class that implements interface #raw("RowChangeProcessor"). #raw("RowChangeProcessor") has one interesting method: #raw("Page transformPage(Page)"). The format of the output page depends on the #raw("RowChangeParadigm").

The connector has no access to the #raw("RowChangeProcessor") instance -- it is used inside the Trino engine to transform the merge page rows into rows to be stored, based on the connector's choice of #raw("RowChangeParadigm").

The page supplied to #raw("transformPage()") consists of:

- The write redistribution columns if any
- For partitioned or bucketed tables, a long hash value column.
- The #raw("rowId") column for the row from the target table if matched, or null if not matched
- The merge case #raw("RowBlock")
- The integer case number block
- The byte #raw("is_distinct") block, with value 0 if not distinct.

The merge case #raw("RowBlock") has the following layout:

- Blocks for each column in the table, including partition columns, in table column order.
- A block containing the boolean "present" value which is true if the source row matched a target row, and false otherwise.
- A block containing the #raw("MERGE") case operation number, encoded as #raw("INSERT") = 1, #raw("DELETE") = 2, #raw("UPDATE") = 3 and if no #raw("MERGE") case matched, -1.
- A block containing the #raw("MERGE") case number, the number starting with 0, for the #raw("WHEN") clause that matched for the row, or -1 if no clause matched.

The page returned from #raw("transformPage") consists of:

- All table columns, in table column order.
- The tinyint type merge case operation block.
- The integer type merge case number block.
- The rowId block remains unchanged from the provided input page.
- A byte block containing 1 if the row is an insert derived from an update operation, and 0 otherwise. This block is used to correctly calculate the count of rows changed for connectors that represent updates and deletes plus inserts.

#raw("transformPage") must ensure that there are no rows whose operation number is -1 in the page it returns.

== Detecting duplicate matching target rows

The SQL #raw("MERGE") specification requires that in each #raw("MERGE") case, a single target table row must match at most one source row, after applying the #raw("MERGE") case condition expression. The first step toward finding these error is done by labeling each row in the target table with a unique id, using an #raw("AssignUniqueId") node above the target table scan. The projected results from the #raw("RIGHT JOIN") have these unique ids for matched target table rows as well as the #raw("WHEN") clause number. A #raw("MarkDistinct") node adds an #raw("is_distinct") column which is true if no other row has the same unique id and #raw("WHEN") clause number, and false otherwise. If any row has #raw("is_distinct") equal to false, a #raw("MERGE_TARGET_ROW_MULTIPLE_MATCHES") exception is raised and the #raw("MERGE") operation fails.

== #raw("ConnectorMergeTableHandle") API

Interface #raw("ConnectorMergeTableHandle") defines one method, #raw("getTableHandle()") to retrieve the #raw("ConnectorTableHandle") originally passed to #raw("ConnectorMetadata.beginMerge()").

== #raw("ConnectorPageSinkProvider") API

To support SQL #raw("MERGE"), #raw("ConnectorPageSinkProvider") must implement the method that creates the #raw("ConnectorMergeSink"):

- #raw("createMergeSink"):
  
  #code-block(none, "ConnectorMergeSink createMergeSink(
      ConnectorTransactionHandle transactionHandle,
      ConnectorSession session,
      ConnectorMergeTableHandle mergeHandle)")

== #raw("ConnectorMergeSink") API

To support #raw("MERGE"), the connector must define an implementation of #raw("ConnectorMergeSink"), usually layered over the connector's #raw("ConnectorPageSink").

The #raw("ConnectorMergeSink") is created by a call to #raw("ConnectorPageSinkProvider.createMergeSink()").

The only interesting methods are:

- #raw("storeMergedRows"):
  
  #code-block(none, "void storeMergedRows(Page page)")
  
  The Trino engine calls the #raw("storeMergedRows(Page)") method of the #raw("ConnectorMergeSink") instance returned by #raw("ConnectorPageSinkProvider.createMergeSink()"), passing the page generated by the #raw("RowChangeProcessor.transformPage()") method. That page consists of all table columns, in table column order, followed by the #raw("TINYINT") operation column, followed by the #raw("INTEGER") merge case number column, followed by the rowId column.
  
  The job of #raw("storeMergedRows()") is iterate over the rows in the page, and process them based on the value of the operation column, #raw("INSERT"), #raw("DELETE"), #raw("UPDATE"), or ignore the row. By choosing appropriate paradigm, the connector can request that the UPDATE operation be transformed into #raw("DELETE") and #raw("INSERT") operations.
- #raw("finish"):
  
  #code-block(none, "CompletableFuture<Collection<Slice>> finish()")
  
  The Trino engine calls #raw("finish()") when all the data has been processed by a specific #raw("ConnectorMergeSink") instance. The connector returns a future containing a collection of #raw("Slice"), representing connector-specific information about the rows processed. Usually this includes the row count, and might include information like the files or partitions created or changed.

== #raw("ConnectorMetadata") #raw("MERGE") API

A connector implementing #raw("MERGE") must implement these #raw("ConnectorMetadata") methods.

- #raw("getRowChangeParadigm()"):
  
  #code-block(none, "RowChangeParadigm getRowChangeParadigm(
      ConnectorSession session,
      ConnectorTableHandle tableHandle)")
  
  This method is called as the engine starts processing a #raw("MERGE") statement. The connector must return a #raw("RowChangeParadigm") enumeration instance. If the connector doesn't support #raw("MERGE"), then it should throw a #raw("NOT_SUPPORTED") exception to indicate that SQL #raw("MERGE") isn't supported by the connector. Note that the default implementation already throws this exception when the method isn't implemented.
- #raw("getMergeRowIdColumnHandle()"):
  
  #code-block(none, "ColumnHandle getMergeRowIdColumnHandle(
      ConnectorSession session,
      ConnectorTableHandle tableHandle)")
  
  This method is called in the early stages of query planning for #raw("MERGE") statements. The ColumnHandle returned provides the #raw("rowId") used by the connector to identify rows to be merged, as well as any other fields of the row that the connector needs to complete the #raw("MERGE") operation.
- #raw("getInsertLayout()"):
  
  #code-block(none, "Optional<ConnectorTableLayout> getInsertLayout(
      ConnectorSession session,
      ConnectorTableHandle tableHandle)")
  
  This method is called during query planning to get the table layout to be used for rows inserted by the #raw("MERGE") operation. For some connectors, this layout is used for rows deleted as well.
- #raw("getUpdateLayout()"):
  
  #code-block(none, "Optional<ConnectorTableLayout> getUpdateLayout(
      ConnectorSession session,
      ConnectorTableHandle tableHandle)")
  
  This method is called during query planning to get the table layout to be used for rows deleted by the #raw("MERGE") operation. If the optional return value is present, the Trino engine uses the layout for updated rows. Otherwise, it uses the result of #raw("ConnectorMetadata.getInsertLayout") to distribute updated rows.
- #raw("beginMerge()"):
  
  #code-block(none, "ConnectorMergeTableHandle beginMerge(
       ConnectorSession session,
       ConnectorTableHandle tableHandle)")
  
  As the last step in creating the #raw("MERGE") execution plan, the connector's #raw("beginMerge()") method is called, passing the #raw("session"), and the #raw("tableHandle").
  
  #raw("beginMerge()") performs any orchestration needed in the connector to start processing the #raw("MERGE"). This orchestration varies from connector to connector. In the case of Hive connector operating on transactional tables, for example, #raw("beginMerge()") checks that the table is transactional and starts a Hive Metastore transaction.
  
  #raw("beginMerge()") returns a #raw("ConnectorMergeTableHandle") with any added information the connector needs when the handle is passed back to #raw("finishMerge()") and the split generation machinery. For most connectors, the returned table handle contains at least a flag identifying the table handle as a table handle for a #raw("MERGE") operation.
- #raw("finishMerge()"):
  
  #code-block(none, "void finishMerge(
      ConnectorSession session,
      ConnectorMergeTableHandle tableHandle,
      Collection<Slice> fragments)")
  
  During #raw("MERGE") processing, the Trino engine accumulates the #raw("Slice") collections returned by #raw("ConnectorMergeSink.finish()"). The engine calls #raw("finishMerge()"), passing the table handle and that collection of #raw("Slice") fragments. In response, the connector takes appropriate actions to complete the #raw("MERGE") operation. Those actions might include committing an underlying transaction, if any, or freeing any other resources.
