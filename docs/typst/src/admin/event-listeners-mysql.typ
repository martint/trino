#import "/lib/trino-docs.typ": *

#anchor("doc-admin-event-listeners-mysql")
= MySQL event listener

The MySQL event listener plugin allows streaming of query events to an external MySQL database. The query history in the database can then be accessed directly in MySQL or via Trino in a catalog using the #link(label("doc-connector-mysql"))[MySQL connector].

== Rationale

This event listener is a first step to store the query history of your Trino cluster. The query events can provide CPU and memory usage metrics, what data is being accessed with resolution down to specific columns, and metadata about the query processing.

Running the capture system separate from Trino reduces the performance impact and avoids downtime for non-client-facing changes.

== Requirements

You need to perform the following steps:

- Create a MySQL database.
- Determine the JDBC connection URL for the database.
- Ensure network access from the Trino coordinator to MySQL is available. Port 3306 is the default port.

#anchor("ref-mysql-event-listener-configuration")

== Configuration

To configure the MySQL event listener plugin, create an event listener properties file in #raw("etc") named #raw("mysql-event-listener.properties") with the following contents as an example:

#code-block("properties", "event-listener.name=mysql
mysql-event-listener.db.url=jdbc:mysql://example.net:3306")

The #raw("mysql-event-listener.db.url") defines the connection to a MySQL database available at the domain #raw("example.net") on port 3306. You can pass further parameters to the MySQL JDBC driver. The supported parameters for the URL are documented in the #link("https://dev.mysql.com/doc/connector-j/en/connector-j-reference-configuration-properties.html")[MySQL Developer Guide].

And set #raw("event-listener.config-files") to #raw("etc/mysql-event-listener.properties") in #link(label("ref-config-properties"))[config-properties]:

#code-block("properties", "event-listener.config-files=etc/mysql-event-listener.properties")

If another event listener is already configured, add the new value #raw("etc/mysql-event-listener.properties") with a separating comma.

After this configuration and successful start of the Trino cluster, the table #raw("trino_queries") is created in the MySQL database. From then on, any query processing event is captured by the event listener and a new row is inserted into the table. The table includes many columns, such as query identifier, query string, user, catalog, and others with information about the query processing.

=== Configuration properties

#list-table((
  ([Property name], [Description],),
  ([#raw("mysql-event-listener.db.url")], [JDBC connection URL to the database including credentials],),
  ([#raw("mysql-event-listener.terminate-on-initialization-failure")], [MySQL event listener initialization can fail if the database is unavailable. This #link(label("ref-prop-type-boolean"))[boolean] switch controls whether to throw an exception in such cases. Defaults to #raw("true").],)
), header-rows: 1)
