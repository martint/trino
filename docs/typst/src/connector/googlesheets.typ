#import "/lib/trino-docs.typ": *

#anchor("doc-connector-googlesheets")
= Google Sheets connector

The Google Sheets connector allows reading and writing #link("https://www.google.com/sheets/about/")[Google Sheets] spreadsheets as tables in Trino.

== Configuration

Create #raw("etc/catalog/example.properties") to mount the Google Sheets connector as the #raw("example") catalog, with the following contents:

#code-block("text", "connector.name=gsheets
gsheets.credentials-path=/path/to/google-sheets-credentials.json
gsheets.metadata-sheet-id=exampleId")

== Configuration properties

The following configuration properties are available:

#list-table((
  ([Property name], [Description],),
  ([#raw("gsheets.credentials-path")], [Path to the Google API JSON key file],),
  ([#raw("gsheets.credentials-key")], [The base64 encoded credentials key],),
  ([#raw("gsheets.delegated-user-email")], [User email to impersonate the service account with domain-wide delegation enabled],),
  ([#raw("gsheets.metadata-sheet-id")], [Sheet ID of the spreadsheet, that contains the table mapping],),
  ([#raw("gsheets.max-data-cache-size")], [Maximum number of spreadsheets to cache, defaults to #raw("1000")],),
  ([#raw("gsheets.data-cache-ttl")], [How long to cache spreadsheet data or metadata, defaults to #raw("5m")],),
  ([#raw("gsheets.connection-timeout")], [Timeout when connection to Google Sheets API, defaults to #raw("20s")],),
  ([#raw("gsheets.read-timeout")], [Timeout when reading from Google Sheets API, defaults to #raw("20s")],),
  ([#raw("gsheets.write-timeout")], [Timeout when writing to Google Sheets API, defaults to #raw("20s")],)
), header-rows: 1)

== Credentials

The connector requires credentials in order to access the Google Sheets API.

+ Open the #link("https://console.developers.google.com/apis/library/sheets.googleapis.com")[Google Sheets API] page and click the #emph[Enable] button. This takes you to the API manager page.
+ Select a project using the drop-down menu at the top of the page. Create a new project, if you do not already have one.
+ Choose #emph[Credentials] in the left panel.
+ Click #emph[Manage service accounts], then create a service account for the connector. On the #emph[Create key] step, create and download a key in JSON format.

The key file needs to be available on the Trino coordinator and workers. Set the #raw("gsheets.credentials-path") configuration property to point to this file. The exact name of the file does not matter -- it can be named anything.

Alternatively, set the #raw("gsheets.credentials-key") configuration property. It should contain the contents of the JSON file, encoded using base64.

Optionally, set the #raw("gsheets.delegated-user-email") property to impersonate a user. This allows you to share Google Sheets with this email instead of the service account.

== Metadata sheet

The metadata sheet is used to map table names to sheet IDs. Create a new metadata sheet. The first row must be a header row containing the following columns in this order:

- Table Name
- Sheet ID
- Owner \(optional\)
- Notes \(optional\)

See this #link("https://docs.google.com/spreadsheets/d/1Es4HhWALUQjoa-bQh4a8B5HROz7dpGMfq_HbfoaW5LM")[example sheet] as a reference.

The metadata sheet must be shared with the service account user, the one for which the key credentials file was created. Click the #emph[Share] button to share the sheet with the email address of the service account.

Set the #raw("gsheets.metadata-sheet-id") configuration property to the ID of this sheet.

== Querying sheets

The service account user must have access to the sheet in order for Trino to query it. Click the #emph[Share] button to share the sheet with the email address of the service account.

The sheet needs to be mapped to a Trino table name. Specify a table name \(column A\) and the sheet ID \(column B\) in the metadata sheet. To refer to a specific range in the sheet, add the range after the sheet ID, separated with #raw("#"). If a range is not provided, the connector loads only 10,000 rows by default from the first tab in the sheet.

The first row of the provided sheet range is used as the header and will determine the column names of the Trino table. For more details on sheet range syntax see the #link("https://developers.google.com/sheets/api/guides/concepts")[google sheets docs].

== Writing to sheets

The same way sheets can be queried, they can also be written by appending data to existing sheets. In this case the service account user must also have #strong[Editor] permissions on the sheet.

After data is written to a table, the table contents are removed from the cache described in #link(label("ref-gsheets-api-usage"))[API usage limits]. If the table is accessed immediately after the write, querying the Google Sheets API may not reflect the change yet. In that case the old version of the table is read and cached for the configured amount of time, and it might take some time for the written changes to propagate properly.

Keep in mind that the Google Sheets API has #link("https://developers.google.com/sheets/api/limits")[usage limits], that limit the speed of inserting data. If you run into timeouts you can increase timeout times to avoid #raw("503: The service is currently unavailable") errors.

#anchor("ref-gsheets-api-usage")

== API usage limits

The Google Sheets API has #link("https://developers.google.com/sheets/api/limits")[usage limits], that may impact the usage of this connector. Increasing the cache duration and\/or size may prevent the limit from being reached. Running queries on the #raw("information_schema.columns") table without a schema and table name filter may lead to hitting the limit, as this requires fetching the sheet data for every table, unless it is already cached.

== Type mapping

Because Trino and Google Sheets each support types that the other does not, this connector #link(label("ref-type-mapping-overview"))[modifies some types] when reading data.

=== Google Sheets type to Trino type mapping

The connector maps Google Sheets types to the corresponding Trino types following this table:

#list-table((
  ([Google Sheets type], [Trino type],),
  ([#raw("TEXT")], [#raw("VARCHAR")],)
), header-rows: 1, title: "Google Sheets type to Trino type mapping")

No other types are supported.

#anchor("ref-google-sheets-sql-support")

== SQL support

In addition to the #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements, this connector supports the following features:

- #link(label("doc-sql-insert"))[INSERT]

=== Table functions

The connector provides specific #link(label("doc-functions-table"))[Table functions] to access Google Sheets.

#anchor("ref-google-sheets-sheet-function")

==== #raw("sheet(id, range) -> table")

The #raw("sheet") function allows you to query a Google Sheet directly without specifying it as a named table in the metadata sheet.

For example, for a catalog named 'example':

#code-block(none, "SELECT *
FROM
  TABLE(example.system.sheet(
      id => 'googleSheetIdHere'));")

A sheet range or named range can be provided as an optional #raw("range") argument. The default sheet range is #raw("$1:$10000") if one is not provided:

#code-block(none, "SELECT *
FROM
  TABLE(example.system.sheet(
      id => 'googleSheetIdHere',
      range => 'TabName!A1:B4'));")
