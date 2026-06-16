#import "/lib/trino-docs.typ": *

#anchor("doc-client-jdbc")
= JDBC driver

The Trino #link("https://wikipedia.org/wiki/JDBC_driver")[JDBC driver] allows users to access Trino using Java-based applications, and other non-Java applications running in a JVM. Both desktop and server-side applications, such as those used for reporting and database development, use the JDBC driver.

The JDBC driver uses the #link(label("doc-client-client-protocol"))[Client protocol] over HTTP\/HTTPS to communicate with the coordinator on the cluster.

== Requirements

The Trino JDBC driver has the following requirements:

- Java version 11 or higher. Java 22 or higher is recommended for improved decompression performance.
- All users that connect to Trino with the JDBC driver must be granted access to query tables in the #raw("system.jdbc") schema.
- Network access over HTTP\/HTTPS to the coordinator of the Trino cluster.
- Network access to the configured object storage, if the #link(label("ref-jdbc-spooling-protocol"))[JDBC driver] is enabled.

The JDBC driver version should be identical to the version of the Trino cluster, or newer. Older versions typically work, but only a subset is regularly tested. Versions before 350 are not supported.

#anchor("ref-jdbc-installation")

== Installation

Download #raw("jdbc") and add it to the classpath of your Java application.

The driver is also available from Maven Central:

#code-block("xml", "<dependency>
    <groupId>io.trino</groupId>
    <artifactId>trino-jdbc</artifactId>
    <version>latest</version>
</dependency>")

We recommend using the latest version of the JDBC driver. A list of all available versions can be found in the #link("https://repo1.maven.org/maven2/io/trino/trino-jdbc/")[Maven Central Repository]. Navigate to the directory for the desired version, and select the #raw("trino-jdbc-xxx.jar") file to download, where #raw("xxx") is the version number.

Once downloaded, you must add the JAR file to a directory in the classpath of users on systems where they will access Trino.

After you have downloaded the JDBC driver and added it to your classpath, you'll typically need to restart your application in order to recognize the new driver. Then, depending on your application, you may need to manually register and configure the driver.

== Registering and configuring the driver

Drivers are commonly loaded automatically by applications once they are added to its classpath. If your application does not, such as is the case for some GUI-based SQL editors, read this section. The steps to register the JDBC driver in a UI or on the command line depend upon the specific application you are using. Please check your application's documentation.

Once registered, you must also configure the connection information as described in the following section.

== Connecting

When your driver is loaded, registered and configured, you are ready to connect to Trino from your application. The following JDBC URL formats are supported:

#code-block("text", "jdbc:trino://host:port
jdbc:trino://host:port/catalog
jdbc:trino://host:port/catalog/schema")

The value for #raw("port") is optional if Trino is available at the default HTTP port #raw("80") or with #raw("SSL=true") and the default HTTPS port #raw("443").

The following is an example of a JDBC URL used to create a connection:

#code-block("text", "jdbc:trino://example.net:8080/hive/sales")

This example JDBC URL locates a Trino instance running on port #raw("8080") on #raw("example.net"), with the catalog #raw("hive") and the schema #raw("sales") defined.

#note[
Typically, the JDBC driver classname is configured automatically by your client. If it is not, use #raw("io.trino.jdbc.TrinoDriver") wherever a driver classname is required.
]

#anchor("ref-jdbc-java-connection")

== Connection parameters

The driver supports various parameters that may be set as URL parameters, or as properties passed to #raw("DriverManager"). Both of the following examples are equivalent:

#code-block("java", "// properties
String url = \"jdbc:trino://example.net:8080/hive/sales\";
Properties properties = new Properties();
properties.setProperty(\"user\", \"test\");
properties.setProperty(\"password\", \"secret\");
properties.setProperty(\"SSL\", \"true\");
Connection connection = DriverManager.getConnection(url, properties);

// URL parameters
String url = \"jdbc:trino://example.net:8443/hive/sales?user=test&password=secret&SSL=true\";
Connection connection = DriverManager.getConnection(url);")

These methods may be mixed; some parameters may be specified in the URL, while others are specified using properties. However, the same parameter may not be specified using both methods.

#anchor("ref-jdbc-parameter-reference")

== Parameter reference

#list-table((
  ([Name], [Description],),
  ([#raw("user")], [Username to use for authentication and authorization.],),
  ([#raw("password")], [Password to use for LDAP authentication.],),
  ([#raw("sessionUser")], [Session username override, used for impersonation.],),
  ([#raw("socksProxy")], [SOCKS proxy host and port. Example: #raw("localhost:1080")],),
  ([#raw("httpProxy")], [HTTP proxy host and port. Example: #raw("localhost:8888")],),
  ([#raw("clientInfo")], [Extra information about the client.],),
  ([#raw("clientTags")], [Client tags for selecting resource groups. Example: #raw("abc,xyz")],),
  ([#raw("path")], [Set the default #link(label("doc-sql-set-path"))[SQL path] for the session. Useful for setting a catalog and schema location for #link(label("ref-udf-catalog"))[Introduction to UDFs].],),
  ([#raw("traceToken")], [Trace token for correlating requests across systems.],),
  ([#raw("source")], [Source name for the Trino query. This parameter should be used in preference to #raw("ApplicationName"). Thus, it takes precedence over #raw("ApplicationName") and\/or #raw("applicationNamePrefix").],),
  ([#raw("applicationNamePrefix")], [Prefix to append to any specified #raw("ApplicationName") client info property, which is used to set the source name for the Trino query if the #raw("source") parameter has not been set. If neither this property nor #raw("ApplicationName") or #raw("source") are set, the source name for the query is #raw("trino-jdbc").],),
  ([#raw("accessToken")], [#link(label("doc-security-jwt"))[JWT] access token for token based authentication.],),
  ([#raw("SSL")], [Set #raw("true") to specify using TLS\/HTTPS for connections.],),
  ([#raw("SSLVerification")], [The method of TLS verification. There are three modes: #raw("FULL") \(default\), #raw("CA") and #raw("NONE"). For #raw("FULL"), the normal TLS verification is performed. For #raw("CA"), only the CA is verified but hostname mismatch is allowed. For #raw("NONE"), there is no verification.],),
  ([#raw("SSLKeyStorePath")], [Use only when connecting to a Trino cluster that has #link(label("doc-security-certificate"))[certificate authentication] enabled. Specifies the path to a #link(label("doc-security-inspect-pem"))[PEM] or #link(label("doc-security-inspect-jks"))[JKS] file, which must contain a certificate that is trusted by the Trino cluster you connect to.],),
  ([#raw("SSLKeyStorePassword")], [The password for the KeyStore, if any.],),
  ([#raw("SSLKeyStoreType")], [The type of the KeyStore. The default type is provided by the Java #raw("keystore.type") security property or #raw("jks") if none exists.],),
  ([#raw("SSLUseSystemKeyStore")], [Set #raw("true") to automatically use the system KeyStore based on the operating system. The supported OSes are Windows and macOS. For Windows, the #raw("Windows-MY") KeyStore is selected. For macOS, the #raw("KeychainStore") KeyStore is selected. For other OSes, the default Java KeyStore is loaded. The KeyStore specification can be overridden using #raw("SSLKeyStoreType").],),
  ([#raw("SSLTrustStorePath")], [The location of the Java TrustStore file to use to validate HTTPS server certificates.],),
  ([#raw("SSLTrustStorePassword")], [The password for the TrustStore.],),
  ([#raw("SSLTrustStoreType")], [The type of the TrustStore. The default type is provided by the Java #raw("keystore.type") security property or #raw("jks") if none exists.],),
  ([#raw("SSLUseSystemTrustStore")], [Set #raw("true") to automatically use the system TrustStore based on the operating system. The supported OSes are Windows and macOS. For Windows, the #raw("Windows-ROOT") TrustStore is selected. For macOS, the #raw("KeychainStore") TrustStore is selected. For other OSes, the default Java TrustStore is loaded. The TrustStore specification can be overridden using #raw("SSLTrustStoreType").],),
  ([#raw("hostnameInCertificate")], [Expected hostname in the certificate presented by the Trino server. Only applicable with full SSL verification enabled.],),
  ([#raw("KerberosRemoteServiceName")], [Trino coordinator Kerberos service name. This parameter is required for Kerberos authentication.],),
  ([#raw("KerberosPrincipal")], [The principal to use when authenticating to the Trino coordinator.],),
  ([#raw("KerberosUseCanonicalHostname")], [Use the canonical hostname of the Trino coordinator for the Kerberos service principal by first resolving the hostname to an IP address and then doing a reverse DNS lookup for that IP address. This is enabled by default.],),
  ([#raw("KerberosServicePrincipalPattern")], [Trino coordinator Kerberos service principal pattern. The default is #raw("${SERVICE}@${HOST}"). #raw("${SERVICE}") is replaced with the value of #raw("KerberosRemoteServiceName") and #raw("${HOST}") is replaced with the hostname of the coordinator \(after canonicalization if enabled\).],),
  ([#raw("KerberosConfigPath")], [Kerberos configuration file.],),
  ([#raw("KerberosKeytabPath")], [Kerberos keytab file.],),
  ([#raw("KerberosCredentialCachePath")], [Kerberos credential cache.],),
  ([#raw("KerberosDelegation")], [Set to #raw("true") to use the token from an existing Kerberos context. This allows client to use Kerberos authentication without passing the Keytab or credential cache. Defaults to #raw("false").],),
  ([#raw("extraCredentials")], [Extra credentials for connecting to external services, specified as a list of key-value pairs. For example, #raw("foo:bar;abc:xyz") creates the credential named #raw("abc") with value #raw("xyz") and the credential named #raw("foo") with value #raw("bar").],),
  ([#raw("roles")], [Authorization roles to use for catalogs, specified as a list of key-value pairs for the catalog and role. For example, #raw("catalog1:roleA;catalog2:roleB") sets #raw("roleA") for #raw("catalog1") and #raw("roleB") for #raw("catalog2").],),
  ([#raw("sessionProperties")], [Session properties to set for the system and for catalogs, specified as a list of key-value pairs. For example, #raw("abc:xyz;example.foo:bar") sets the system property #raw("abc") to the value #raw("xyz") and the #raw("foo") property for catalog #raw("example") to the value #raw("bar").],),
  ([#raw("extraHeaders")], [HTTP headers to add to the authenticated HTTP requests, specified as a list of key-value pairs. For example, #raw("X-Trino-Foo:xyz;X-Trino-Bar:bar") sends the #raw("X-Trino-Foo") header with the value #raw("xyz") and the #raw("X-Trino-Bar") header with the value #raw("bar"). Protocol headers such as #raw("X-Trino-User") cannot be overridden using this parameter.],),
  ([#raw("externalAuthentication")], [Set to true if you want to use external authentication via #link(label("doc-security-oauth2"))[OAuth 2.0 authentication]. Use a local web browser to authenticate with an identity provider \(IdP\) that has been configured for the Trino coordinator.],),
  ([#raw("externalAuthenticationTokenCache")], [Allows the sharing of external authentication tokens between different connections for the same authenticated user until the cache is invalidated, such as when a client is restarted or when the classloader reloads the JDBC driver. This is disabled by default, with a value of #raw("NONE"). Set the value to #raw("MEMORY") to cache the token in memory within the same process. Set the value to #raw("SYSTEM") to persist the token to the filesystem \(#raw("~/.trino/")\), allowing it to be reused across separate CLI or JDBC processes. If the JDBC driver is used in a shared mode by different users, the first registered token is stored and authenticates all users.],),
  ([#raw("disableCompression")], [Whether HTTP compression should be disabled. Defaults to #raw("false").],),
  ([#raw("disallowLocalRedirect")], [Whether client should reject redirects to localhost, link or site local IP addresses. Defaults to #raw("false").],),
  ([#raw("assumeLiteralUnderscoreInMetadataCallsForNonConformingClients")], [When enabled, the name patterns passed to #raw("DatabaseMetaData") methods are treated as underscores. You can use this as a workaround for applications that do not escape schema or table names when passing them to #raw("DatabaseMetaData") methods as schema or table name patterns.],),
  ([#raw("timezone")], [Sets the time zone for the session using the #link("https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/time/ZoneId.html#of(java.lang.String)")[time zone passed]. Defaults to the timezone of the JVM running the JDBC driver.],),
  ([#raw("explicitPrepare")], [Defaults to #raw("true"). When set to #raw("false"), prepared statements are executed calling a single #raw("EXECUTE IMMEDIATE") query instead of the standard #raw("PREPARE <statement>") followed by #raw("EXECUTE <statement>"). This reduces network overhead and uses smaller HTTP headers and requires Trino 431 or greater.],),
  ([#raw("encoding")], [Set the encoding when using the #link(label("ref-jdbc-spooling-protocol"))[spooling protocol]. Valid values are JSON with Zstandard compression, #raw("json+zstd") \(recommended\), JSON with LZ4 compression #raw("json+lz4"), and uncompressed JSON #raw("json"). By default, the default encoding configured on the cluster is used.],),
  ([#raw("validateConnection")], [Defaults to #raw("false"). If set to #raw("true"), connectivity and credentials are validated when the connection is created, and when #raw("java.sql.Connection.isValid(int)") is called.],)
), header-rows: 1)

#anchor("ref-jdbc-spooling-protocol")

== Spooling protocol

The Trino JDBC driver automatically uses of the spooling protocol to improve throughput for client interactions with higher data transfer demands, if the #link(label("ref-protocol-spooling"))[Client protocol] is configured on the cluster.

Optionally use the #raw("encoding") parameter to configure a different desired encoding, compared to the default on the cluster.

The JVM process using the JDBC driver must have network access to the spooling object storage.
