#import "/lib/trino-docs.typ": *

#anchor("doc-client-cli")
= Command line interface

The Trino CLI provides a terminal-based, interactive shell for running queries. The CLI is a #link("http://skife.org/java/unix/2011/06/20/really_executable_jars.html")[self-executing] JAR file, which means it acts like a normal UNIX executable.

The CLI uses the #link(label("doc-client-client-protocol"))[Client protocol] over HTTP\/HTTPS to communicate with the coordinator on the cluster.

== Requirements

The Trino CLI has the following requirements:

- Java version 11 or higher available on the path. Java 22 or higher is recommended for improved decompression performance.
- Network access over HTTP\/HTTPS to the coordinator of the Trino cluster.
- Network access to the configured object storage, if the #link(label("ref-cli-spooling-protocol"))[Command line interface] is enabled.

The CLI version should be identical to the version of the Trino cluster, or newer. Older versions typically work, but only a subset is regularly tested. Versions before 350 are not supported.

#anchor("ref-cli-installation")

== Installation

Download #raw("cli"), rename it to #raw("trino"), make it executable with #raw("chmod +x"), and run it to show the version of the CLI:

#code-block("text", "./trino --version")

Run the CLI with #raw("--help") or #raw("-h") to see all available options.

Windows users, and users unable to execute the preceding steps, can use the equivalent #raw("java") command with the #raw("-jar") option to run the CLI, and show the version:

#code-block("text", "java -jar trino-cli-*-executable.jar --version")

The syntax can be used for the examples in the following sections. In addition, using the #raw("java") command allows you to add configuration options for the Java runtime with the #raw("-D") syntax. You can use this for debugging and troubleshooting, such as when #link(label("ref-cli-kerberos-debug"))[specifying additional Kerberos debug options].

== Running the CLI

The minimal command to start the CLI in interactive mode specifies the URL of the coordinator in the Trino cluster:

#code-block("text", "./trino http://trino.example.com:8080")

If successful, you will get a prompt to execute commands. Use the #raw("help") command to see a list of supported commands. Use the #raw("clear") command to clear the terminal. To stop and exit the CLI, run #raw("exit") or #raw("quit").:

#code-block("text", "trino> help

Supported commands:
QUIT
EXIT
CLEAR
EXPLAIN [ ( option [, ...] ) ] <query>
    options: FORMAT { TEXT | GRAPHVIZ | JSON }
            TYPE { LOGICAL | DISTRIBUTED | VALIDATE | IO }
DESCRIBE <table>
SHOW COLUMNS FROM <table>
SHOW FUNCTIONS
SHOW CATALOGS [LIKE <pattern>]
SHOW SCHEMAS [FROM <catalog>] [LIKE <pattern>]
SHOW TABLES [FROM <schema>] [LIKE <pattern>]
USE [<catalog>.]<schema>")

You can now run SQL statements. After processing, the CLI will show results and statistics.

#code-block("text", "trino> SELECT count(*) FROM tpch.tiny.nation;

_col0
-------
    25
(1 row)

Query 20220324_213359_00007_w6hbk, FINISHED, 1 node
Splits: 13 total, 13 done (100.00%)
2.92 [25 rows, 0B] [8 rows/s, 0B/s]")

As part of starting the CLI, you can set the default catalog and schema. This allows you to query tables directly without specifying catalog and schema.

#code-block("text", "./trino http://trino.example.com:8080/tpch/tiny

trino:tiny> SHOW TABLES;

  Table
----------
customer
lineitem
nation
orders
part
partsupp
region
supplier
(8 rows)")

You can also set the default catalog and schema with the #link(label("doc-sql-use"))[USE] statement.

#code-block("text", "trino> USE tpch.tiny;
USE
trino:tiny>")

Many other options are available to further configure the CLI in interactive mode:

#list-table((
  ([Option], [Description],),
  ([#raw("--catalog")], [Sets the default catalog. Optionally also use #raw("--schema") to set the default schema. You can change the default catalog and default schema with#link(label("doc-sql-use"))[USE].],),
  ([#raw("--client-info")], [Adds arbitrary text as extra information about the client.],),
  ([#raw("--client-request-timeout")], [Sets the duration for query processing, after which, the client request is terminated. Defaults to #raw("2m").],),
  ([#raw("--client-tags")], [Adds extra tags information about the client and the CLI user. Separate multiple tags with commas. The tags can be used as input for #link(label("doc-admin-resource-groups"))[Resource groups].],),
  ([#raw("--debug")], [Enables display of debug information during CLI usage for #link(label("ref-cli-troubleshooting"))[Command line interface]. Displays more information about query processing statistics.],),
  ([#raw("--decimal-data-size")], [Show data size and rate in base 10 \(kB, MB, etc.\) rather than the default base 2 \(KiB, MiB, etc.\).],),
  ([#raw("--disable-auto-suggestion")], [Disables autocomplete suggestions.],),
  ([#raw("--disable-compression")], [Disables compression of query results.],),
  ([#raw("--editing-mode")], [Sets key bindings in the CLI to be compatible with VI or EMACS editors. Defaults to #raw("EMACS").],),
  ([#raw("--extra-credential")], [Extra credentials \(property can be used multiple times; format is key=value\)],),
  ([#raw("--extra-header")], [HTTP header to add to the authenticated HTTP requests \(property can be used multiple times; format is key=value\).],),
  ([#raw("--http-proxy")], [Configures the URL of the HTTP proxy to connect to Trino.],),
  ([#raw("--history-file")], [Path to the #link(label("ref-cli-history"))[history file]. Defaults to #raw("~/.trino_history").],),
  ([#raw("--network-logging")], [Configures the level of detail provided for network logging of the CLI. Defaults to #raw("NONE"), other options are #raw("BASIC"), #raw("HEADERS"), or #raw("BODY").],),
  ([#raw("--output-format-interactive=<format>")], [Specify the #link(label("ref-cli-output-format"))[format] to use for printing query results. Defaults to #raw("ALIGNED").],),
  ([#raw("--pager=<pager>")], [Path to the pager program used to display the query results. Set to an empty value to completely disable pagination. Defaults to #raw("less") with a carefully selected set of options.],),
  ([#raw("--no-progress")], [Do not show query processing progress.],),
  ([#raw("--path")], [Set the default #link(label("doc-sql-set-path"))[SQL path] for the session. Useful for setting a catalog and schema location for #link(label("ref-udf-catalog"))[Introduction to UDFs].],),
  ([#raw("--password")], [Prompts for a password. Use if your Trino server requires password authentication. You can set the #raw("TRINO_PASSWORD") environment variable with the password value to avoid the prompt. For more information, see #link(label("ref-cli-username-password-auth"))[Command line interface].],),
  ([#raw("--schema")], [Sets the default schema. Must be combined with #raw("--catalog"). You can change the default catalog and default schema with #link(label("doc-sql-use"))[USE].],),
  ([#raw("--server")], [The HTTP\/HTTPS address and port of the Trino coordinator. The port must be set to the port the Trino coordinator is listening for connections on. Port 80 for HTTP and Port 443 for HTTPS can be omitted. Trino server location defaults to #raw("http://localhost:8080"). Can only be set if URL is not specified.],),
  ([#raw("--session")], [Sets one or more #link(label("ref-session-properties-definition"))[session properties]. Property can be used multiple times with the format #raw("session_property_name=value").],),
  ([#raw("--socks-proxy")], [Configures the URL of the SOCKS proxy to connect to Trino.],),
  ([#raw("--source")], [Specifies the name of the application or source connecting to Trino. Defaults to #raw("trino-cli"). The value can be used as input for #link(label("doc-admin-resource-groups"))[Resource groups].],),
  ([#raw("--timezone")], [Sets the time zone for the session using the #link("https://wikipedia.org/wiki/List_of_tz_database_time_zones")[time zone name]. Defaults to the timezone set on your workstation.],),
  ([#raw("--user")], [Sets the username for #link(label("ref-cli-username-password-auth"))[Command line interface]. Defaults to your operating system username. You can override the default username, if your cluster uses a different username or authentication mechanism.],)
), header-rows: 1)

Most of the options can also be set as parameters in the URL. This means a JDBC URL can be used in the CLI after removing the #raw("jdbc:") prefix. However, the same parameter may not be specified using both methods. See #link(label("doc-client-jdbc"))[the JDBC driver parameter reference] to find out URL parameter names. For example:

#code-block("text", "./trino 'https://trino.example.com?SSL=true&SSLVerification=FULL&clientInfo=extra'")

#anchor("ref-cli-tls")

== TLS\/HTTPS

Trino is typically available with an HTTPS URL. This means that all network traffic between the CLI and Trino uses TLS. #link(label("doc-security-tls"))[TLS configuration] is common, since it is a requirement for #link(label("ref-cli-authentication"))[any authentication].

Use the HTTPS URL to connect to the server:

#code-block("text", "./trino https://trino.example.com")

The recommended TLS implementation is to use a globally trusted certificate. In this case, no other options are necessary, since the JVM running the CLI recognizes these certificates.

Use the options from the following table to further configure TLS and certificate usage:

#list-table((
  ([Option], [Description],),
  ([#raw("--insecure")], [Skip certificate validation when connecting with TLS\/HTTPS \(should only be used for debugging\).],),
  ([#raw("--keystore-path")], [The location of the Java Keystore file that contains the certificate of the server to connect with TLS.],),
  ([#raw("--keystore-password")], [The password for the keystore. This must match the password you specified when creating the keystore.],),
  ([#raw("--keystore-type")], [Determined by the keystore file format. The default keystore type is JKS. This advanced option is only necessary if you use a custom Java Cryptography Architecture \(JCA\) provider implementation.],),
  ([#raw("--use-system-keystore")], [Use a client certificate obtained from the system keystore of the operating system. Windows and macOS are supported. For other operating systems, the default Java keystore is used. The keystore type can be overridden using #raw("--keystore-type").],),
  ([#raw("--truststore-password")], [The password for the truststore. This must match the password you specified when creating the truststore.],),
  ([#raw("--truststore-path")], [The location of the Java truststore file that will be used to secure TLS.],),
  ([#raw("--truststore-type")], [Determined by the truststore file format. The default keystore type is JKS. This advanced option is only necessary if you use a custom Java Cryptography Architecture \(JCA\) provider implementation.],),
  ([#raw("--use-system-truststore")], [Verify the server certificate using the system truststore of the operating system. Windows and macOS are supported. For other operating systems, the default Java truststore is used. The truststore type can be overridden using #raw("--truststore-type").],)
), header-rows: 1)

#anchor("ref-cli-authentication")

== Authentication

The Trino CLI supports many #link(label("doc-security-authentication-types"))[Authentication types] detailed in the following sections:

#anchor("ref-cli-username-password-auth")

=== Username and password authentication

Username and password authentication is typically configured in a cluster using the #raw("PASSWORD") #link(label("doc-security-authentication-types"))[authentication type], for example with #link(label("doc-security-ldap"))[LDAP authentication] or #link(label("doc-security-password-file"))[Password file authentication].

The following code example connects to the server, establishes your username, and prompts the CLI for your password:

#code-block("text", "./trino https://trino.example.com --user=exampleusername --password")

Alternatively, set the password as the value of the #raw("TRINO_PASSWORD") environment variable. Typically use single quotes to avoid problems with special characters such as #raw("$"):

#code-block("text", "export TRINO_PASSWORD='LongSecurePassword123!@#'")

If the #raw("TRINO_PASSWORD") environment variable is set, you are not prompted to provide a password to connect with the CLI.

#code-block("text", "./trino https://trino.example.com --user=exampleusername --password")

#anchor("ref-cli-external-sso-auth")

=== External authentication - SSO

Use the #raw("--external-authentication") option for browser-based SSO authentication, as detailed in #link(label("doc-security-oauth2"))[OAuth 2.0 authentication]. With this configuration, the CLI displays a URL that you must open in a web browser for authentication.

The detailed behavior is as follows:

- Start the CLI with the #raw("--external-authentication") option and execute a query.
- The CLI starts and connects to Trino.
- A message appears in the CLI directing you to open a browser with a specified URL when the first query is submitted.
- Open the URL in a browser and follow through the authentication process.
- The CLI automatically receives a token.
- When successfully authenticated in the browser, the CLI proceeds to execute the query.
- Further queries in the CLI session do not require additional logins while the authentication token remains valid. Token expiration depends on the external authentication type configuration.
- Expired tokens force you to log in again.

#anchor("ref-cli-certificate-auth")

=== Certificate authentication

Use the following CLI arguments to connect to a cluster that uses #link(label("doc-security-certificate"))[certificate authentication].

#list-table((
  ([Option], [Description],),
  ([#raw("--keystore-path=<path>")], [Absolute or relative path to a #link(label("doc-security-inspect-pem"))[PEM] or #link(label("doc-security-inspect-jks"))[JKS] file, which must contain a certificate that is trusted by the Trino cluster you are connecting to.],),
  ([#raw("--keystore-password=<password>")], [Only required if the keystore has a password.],)
), header-rows: 1, title: "CLI options for certificate authentication")

The truststore related options are independent of client certificate authentication with the CLI; instead, they control the client's trust of the server's certificate.

#anchor("ref-cli-jwt-auth")

=== JWT authentication

To access a Trino cluster configured to use #link(label("doc-security-jwt"))[JWT authentication], use the #raw("--access-token=<token>") option to pass a JWT to the server.

#anchor("ref-cli-kerberos-auth")

=== Kerberos authentication

The Trino CLI can connect to a Trino cluster that has #link(label("doc-security-kerberos"))[Kerberos authentication] enabled.

Invoking the CLI with Kerberos support enabled requires a number of additional command line options. You also need the #link(label("ref-server-kerberos-principals"))[Kerberos configuration files] for your user on the machine running the CLI. The simplest way to invoke the CLI is with a wrapper script:

#code-block("text", "#!/bin/bash

./trino \\
  --server https://trino.example.com \\
  --krb5-config-path /etc/krb5.conf \\
  --krb5-principal someuser@EXAMPLE.COM \\
  --krb5-keytab-path /home/someuser/someuser.keytab \\
  --krb5-remote-service-name trino")

When using Kerberos authentication, access to the Trino coordinator must be through #link(label("doc-security-tls"))[TLS and HTTPS].

The following table lists the available options for Kerberos authentication:

#list-table((
  ([Option], [Description],),
  ([#raw("--krb5-config-path")], [Path to Kerberos configuration files.],),
  ([#raw("--krb5-credential-cache-path")], [Kerberos credential cache path.],),
  ([#raw("--krb5-disable-remote-service-hostname-canonicalization")], [Disable service hostname canonicalization using the DNS reverse lookup.],),
  ([#raw("--krb5-keytab-path")], [The location of the keytab that can be used to authenticate the principal specified by #raw("--krb5-principal").],),
  ([#raw("--krb5-principal")], [The principal to use when authenticating to the coordinator.],),
  ([#raw("--krb5-remote-service-name")], [Trino coordinator Kerberos service name.],),
  ([#raw("--krb5-service-principal-pattern")], [Remote kerberos service principal pattern. Defaults to #raw("${SERVICE}@${HOST}").],)
), header-rows: 1, title: "CLI options for Kerberos authentication")

#anchor("ref-cli-kerberos-debug")

==== Additional Kerberos debugging information

You can enable additional Kerberos debugging information for the Trino CLI process by passing #raw("-Dsun.security.krb5.debug=true"), #raw("-Dtrino.client.debugKerberos=true"), and #raw("-Djava.security.debug=gssloginconfig,configfile,configparser,logincontext") as a JVM argument when #link(label("ref-cli-installation"))[starting the CLI process]:

#code-block("text", "java \\
  -Dsun.security.krb5.debug=true \\
  -Djava.security.debug=gssloginconfig,configfile,configparser,logincontext \\
  -Dtrino.client.debugKerberos=true \\
  -jar trino-cli-*-executable.jar \\
  --server https://trino.example.com \\
  --krb5-config-path /etc/krb5.conf \\
  --krb5-principal someuser@EXAMPLE.COM \\
  --krb5-keytab-path /home/someuser/someuser.keytab \\
  --krb5-remote-service-name trino")

For help with interpreting Kerberos debugging messages, see #link(label("ref-kerberos-debug"))[additional resources].

== Pagination

By default, the results of queries are paginated using the #raw("less") program which is configured with a carefully selected set of options. This behavior can be overridden by setting the #raw("--pager") option or the #raw("TRINO_PAGER") environment variable to the name of a different program such as #raw("more") or #link("https://github.com/okbob/pspg")[pspg], or it can be set to an empty value to completely disable pagination.

#anchor("ref-cli-history")

== History

The CLI keeps a history of your previously used commands. You can access your history by scrolling or searching. Use the up and down arrows to scroll and #kbd("Control+S") and #kbd("Control+R") to search. To execute a query again, press #kbd("Enter").

By default, you can locate the Trino history file in #raw("~/.trino_history"). Use the #raw("--history-file") option or the #raw("TRINO_HISTORY_FILE") environment variable to change the default.

=== Auto suggestion

The CLI generates autocomplete suggestions based on command history.

Press #kbd("→") to accept the suggestion and replace the current command line buffer. Press #kbd("Ctrl+→") \(#kbd("Option+→") on Mac\) to accept only the next keyword. Continue typing to reject the suggestion.

== Configuration file

The CLI can read default values for all options from a file. It uses the first file found from the ordered list of locations:

- File path set as value of the #raw("TRINO_CONFIG") environment variable.
- #raw(".trino_config") in the current users home directory.
- #raw("$XDG_CONFIG_HOME/trino/config").

For example, you could create separate configuration files with different authentication options, like #raw("kerberos-cli.properties") and #raw("ldap-cli.properties"). Assuming they're located in the current directory, you can set the #raw("TRINO_CONFIG") environment variable for a single invocation of the CLI by adding it before the #raw("trino") command:

#code-block("text", "TRINO_CONFIG=kerberos-cli.properties trino https://first-cluster.example.com:8443
TRINO_CONFIG=ldap-cli.properties trino https://second-cluster.example.com:8443")

In the preceding example, the default configuration files are not used.

You can use all supported options without the #raw("--") prefix in the configuration properties file. Options that normally don't take an argument are boolean, so set them to either #raw("true") or #raw("false"). For example:

#code-block("properties", "output-format-interactive=AUTO
timezone=Europe/Warsaw
user=trino-client
network-logging=BASIC
krb5-disable-remote-service-hostname-canonicalization=true")

== Batch mode

Running the Trino CLI with the #raw("--execute"), #raw("--file"), or passing queries to the standard input uses the batch \(non-interactive\) mode. In this mode the CLI does not report progress, and exits after processing the supplied queries. Results are printed in #raw("CSV") format by default. You can configure other formats and redirect the output to a file.

The following options are available to further configure the CLI in batch mode:

#list-table((
  ([Option], [Description],),
  ([#raw("--execute=<execute>")], [Execute specified statements and exit.],),
  ([#raw("-f"), #raw("--file=<file>")], [Execute statements from file and exit.],),
  ([#raw("--ignore-errors")], [Continue processing in batch mode when an error occurs. Default is to exit immediately.],),
  ([#raw("--output-format=<format>")], [Specify the #link(label("ref-cli-output-format"))[format] to use for printing query results. Defaults to #raw("CSV").],),
  ([#raw("--progress")], [Show query progress in batch mode. It does not affect the output, which, for example can be safely redirected to a file.],)
), header-rows: 1)

=== Examples

Consider the following command run as shown, or with the #raw("--output-format=CSV") option, which is the default for non-interactive usage:

#code-block("text", "trino --execute 'SELECT nationkey, name, regionkey FROM tpch.sf1.nation LIMIT 3'")

The output is as follows:

#code-block("text", "\"0\",\"ALGERIA\",\"0\"
\"1\",\"ARGENTINA\",\"1\"
\"2\",\"BRAZIL\",\"1\"")

The output with the #raw("--output-format=JSON") option:

#code-block("json", "{\"nationkey\":0,\"name\":\"ALGERIA\",\"regionkey\":0}
{\"nationkey\":1,\"name\":\"ARGENTINA\",\"regionkey\":1}
{\"nationkey\":2,\"name\":\"BRAZIL\",\"regionkey\":1}")

The output with the #raw("--output-format=ALIGNED") option, which is the default for interactive usage:

#code-block("text", "nationkey |   name    | regionkey
----------+-----------+----------
        0 | ALGERIA   |         0
        1 | ARGENTINA |         1
        2 | BRAZIL    |         1")

The output with the #raw("--output-format=VERTICAL") option:

#code-block("text", "-[ RECORD 1 ]--------
nationkey | 0
name      | ALGERIA
regionkey | 0
-[ RECORD 2 ]--------
nationkey | 1
name      | ARGENTINA
regionkey | 1
-[ RECORD 3 ]--------
nationkey | 2
name      | BRAZIL
regionkey | 1")

The preceding command with #raw("--output-format=NULL") produces no output. However, if you have an error in the query, such as incorrectly using #raw("region") instead of #raw("regionkey"), the command has an exit status of 1 and displays an error message \(which is unaffected by the output format\):

#code-block("text", "Query 20200707_170726_00030_2iup9 failed: line 1:25: Column 'region' cannot be resolved
SELECT nationkey, name, region FROM tpch.sf1.nation LIMIT 3")

#anchor("ref-cli-spooling-protocol")

== Spooling protocol

The Trino CLI automatically uses the spooling protocol to improve throughput for client interactions with higher data transfer demands, if the #link(label("ref-protocol-spooling"))[Client protocol] is configured on the cluster.

Optionally use the #raw("--encoding") option to configure a different desired encoding, compared to the default on the cluster. The available values are #raw("json+zstd") \(recommended\) for JSON with Zstandard compression, and #raw("json+lz4") for JSON with LZ4 compression, and #raw("json") for uncompressed JSON.

The CLI process must have network access to the spooling object storage.

#anchor("ref-cli-output-format")

== Output formats

The Trino CLI provides the options #raw("--output-format") and #raw("--output-format-interactive") to control how the output is displayed. The available options shown in the following table must be entered in uppercase. The default value is #raw("ALIGNED") in interactive mode, and #raw("CSV") in non-interactive mode.

#list-table((
  ([Option], [Description],),
  ([#raw("CSV")], [Comma-separated values, each value quoted. No header row.],),
  ([#raw("CSV_HEADER")], [Comma-separated values, quoted with header row.],),
  ([#raw("CSV_UNQUOTED")], [Comma-separated values without quotes.],),
  ([#raw("CSV_HEADER_UNQUOTED")], [Comma-separated values with header row but no quotes.],),
  ([#raw("TSV")], [Tab-separated values.],),
  ([#raw("TSV_HEADER")], [Tab-separated values with header row.],),
  ([#raw("JSON")], [Output rows emitted as JSON objects with name-value pairs.],),
  ([#raw("ALIGNED")], [Output emitted as an ASCII character table with values.],),
  ([#raw("VERTICAL")], [Output emitted as record-oriented top-down lines, one per value.],),
  ([#raw("AUTO")], [Same as #raw("ALIGNED") if output would fit the current terminal width, and #raw("VERTICAL") otherwise.],),
  ([#raw("MARKDOWN")], [Output emitted as a Markdown table.],),
  ([#raw("NULL")], [Suppresses normal query results. This can be useful during development to test a query's shell return code or to see whether it results in error messages.],)
), header-rows: 1, title: "Output format options")

#anchor("ref-cli-troubleshooting")

== Troubleshooting

If something goes wrong, you see an error message:

#code-block("text", "$ trino
trino> select count(*) from tpch.tiny.nations;
Query 20200804_201646_00003_f5f6c failed: line 1:22: Table 'tpch.tiny.nations' does not exist
select count(*) from tpch.tiny.nations")

To view debug information, including the stack trace for failures, use the #raw("--debug") option:

#code-block("text", "$ trino --debug
trino> select count(*) from tpch.tiny.nations;
Query 20200804_201629_00002_f5f6c failed: line 1:22: Table 'tpch.tiny.nations' does not exist
io.trino.spi.TrinoException: line 1:22: Table 'tpch.tiny.nations' does not exist
at io.trino.sql.analyzer.SemanticExceptions.semanticException(SemanticExceptions.java:48)
at io.trino.sql.analyzer.SemanticExceptions.semanticException(SemanticExceptions.java:43)
...
at java.base/java.lang.Thread.run(Thread.java:834)
select count(*) from tpch.tiny.nations")
