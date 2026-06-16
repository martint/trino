#import "/lib/trino-docs.typ": *

#anchor("doc-develop-insert")
= Supporting #raw("INSERT") and #raw("CREATE TABLE AS")

To support #raw("INSERT"), a connector must implement:

- #raw("beginInsert()") and #raw("finishInsert()") from the #raw("ConnectorMetadata") interface;
- a #raw("ConnectorPageSinkProvider") that receives a table handle and returns a #raw("ConnectorPageSink").

When executing an #raw("INSERT") statement, the engine calls the #raw("beginInsert()") method in the connector, which receives a table handle and a list of columns. It should return a #raw("ConnectorInsertTableHandle"), that can carry any connector specific information, and it's passed to the page sink provider. The #raw("PageSinkProvider") creates a page sink, that accepts #raw("Page") objects.

When all the pages for a specific split have been processed, Trino calls #raw("ConnectorPageSink.finish()"), which returns a #raw("Collection<Slice>") of fragments representing connector-specific information about the processed rows.

When all pages for all splits have been processed, Trino calls #raw("ConnectorMetadata.finishInsert()"), passing a collection containing all the fragments from all the splits. The connector does what is required to finalize the operation, for example, committing the transaction.

To support #raw("CREATE TABLE AS"), the #raw("ConnectorPageSinkProvider") must also return a page sink when receiving a #raw("ConnectorOutputTableHandle"). This handle is returned from #raw("ConnectorMetadata.beginCreateTable()").
