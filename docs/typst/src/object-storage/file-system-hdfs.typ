#import "/lib/trino-docs.typ": *

#anchor("doc-object-storage-file-system-hdfs")
= HDFS file system support

Trino includes support to access the #link("https://hadoop.apache.org/")[Hadoop Distributed File System \(HDFS\)] with a catalog using the Delta Lake, Hive, Hudi, or Iceberg connectors.

Support for HDFS is not enabled by default, but can be activated by setting the #raw("fs.hadoop.enabled") property to #raw("true") in your catalog configuration file.

Apache Hadoop HDFS 2.x and 3.x are supported.

== General configuration

Use the following properties to configure general aspects of HDFS support:

#list-table((
  ([Property], [Description],),
  ([#raw("fs.hadoop.enabled")], [Activate the support for HDFS access. Defaults to #raw("false"). Set to #raw("true") to use HDFS and enable all other properties.],),
  ([#raw("hive.config.resources")], [An optional, comma-separated list of HDFS configuration files. These files must exist on the machines running Trino. For basic setups, Trino configures the HDFS client automatically and does not require any configuration files. In some cases, such as when using federated HDFS or NameNode high availability, it is necessary to specify additional HDFS client options to access your HDFS cluster in the HDFS XML configuration files and reference them with this parameter:

#code-block("text", "hive.config.resources=/etc/hadoop/conf/core-site.xml")

Only specify additional configuration files if necessary for your setup, and reduce the configuration files to have the minimum set of required properties. Additional properties may cause problems.],),
  ([#raw("hive.fs.new-directory-permissions")], [Controls the permissions set on new directories created for schemas and tables. Value must either be #raw("skip") or an octal number, with a leading 0. If set to #raw("skip"), permissions of newly created directories are not set by Trino. Defaults to #raw("0777").],),
  ([#raw("hive.dfs.verify-checksum")], [Flag to determine if file checksums must be verified. Defaults to #raw("false").],),
  ([#raw("hive.dfs.ipc-ping-interval")], [#link(label("ref-prop-type-duration"))[Duration] between IPC pings from Trino to HDFS. Defaults to #raw("10s").],),
  ([#raw("hive.dfs-timeout")], [Timeout #link(label("ref-prop-type-duration"))[duration] for access operations on HDFS. Defaults to #raw("60s").],),
  ([#raw("hive.dfs.connect.timeout")], [Timeout #link(label("ref-prop-type-duration"))[duration] for connection operations to HDFS. Defaults to #raw("500ms").],),
  ([#raw("hive.dfs.connect.max-retries")], [Maximum number of retries for HDFS connection attempts. Defaults to #raw("5").],),
  ([#raw("hive.dfs.key-provider.cache-ttl")], [Caching time #link(label("ref-prop-type-duration"))[duration] for the key provider. Defaults to #raw("30min").],),
  ([#raw("hive.dfs.domain-socket-path")], [Path to the UNIX domain socket for the DataNode. The path must exist on each node. For example, #raw("/var/lib/hadoop-hdfs/dn_socket").],),
  ([#raw("hive.hdfs.socks-proxy")], [URL for a SOCKS proxy to use for accessing HDFS. For example, #raw("hdfs-master:1180").],),
  ([#raw("hive.hdfs.wire-encryption.enabled")], [Enable HDFS wire encryption. In a Kerberized Hadoop cluster that uses HDFS wire encryption, this must be set to #raw("true") to enable Trino to access HDFS. Note that using wire encryption may impact query execution performance. Defaults to #raw("false").],),
  ([#raw("hive.fs.cache.max-size")], [Maximum number of cached file system objects in the HDFS cache. Defaults to #raw("1000").],),
  ([#raw("hive.dfs.replication")], [Integer value to set the HDFS replication factor. By default, no value is set.],)
), header-rows: 1)

== Security

HDFS support includes capabilities for user impersonation and Kerberos authentication. The following properties are available:

#list-table((
  ([Property value], [Description],),
  ([#raw("hive.hdfs.authentication.type")], [Configure the authentication to use no authentication \(#raw("NONE")\) or Kerberos authentication \(#raw("KERBEROS")\). Defaults to #raw("NONE").],),
  ([#raw("hive.hdfs.impersonation.enabled")], [Enable HDFS end-user impersonation. Defaults to #raw("false"). See details in #link(label("ref-hdfs-security-impersonation"))[HDFS file system support].],),
  ([#raw("hive.hdfs.trino.principal")], [The Kerberos principal Trino uses when connecting to HDFS. Example: #raw("trino-hdfs-superuser/trino-server-node@EXAMPLE.COM") or #raw("trino-hdfs-superuser/_HOST@EXAMPLE.COM").

The #raw("_HOST") placeholder can be used in this property value. When connecting to HDFS, the Hive connector substitutes in the hostname of the #strong[worker] node Trino is running on. This is useful if each worker node has its own Kerberos principal.],),
  ([#raw("hive.hdfs.trino.keytab")], [The path to the keytab file that contains a key for the principal specified by #raw("hive.hdfs.trino.principal"). This file must be readable by the operating system user running Trino.],),
  ([#raw("hive.hdfs.trino.credential-cache.location")], [The location of the credential-cache with the credentials for the principal to use to access HDFS. Alternative to #raw("hive.hdfs.trino.keytab").],)
), header-rows: 1)

The default security configuration does not use authentication when connecting to a Hadoop cluster \(#raw("hive.hdfs.authentication.type=NONE")\). All queries are executed as the OS user who runs the Trino process, regardless of which user submits the query.

Before running any #raw("CREATE TABLE") or #raw("CREATE TABLE AS") statements for Hive tables in Trino, you must check that the user Trino is using to access HDFS has access to the Hive warehouse directory. The Hive warehouse directory is specified by the configuration variable #raw("hive.metastore.warehouse.dir") in #raw("hive-site.xml"), and the default value is #raw("/user/hive/warehouse").

For example, if Trino is running as #raw("nobody"), it accesses HDFS as #raw("nobody"). You can override this username by setting the #raw("HADOOP_USER_NAME") system property in the Trino #link(label("ref-jvm-config"))[Deploying Trino], replacing #raw("hdfs_user") with the appropriate username:

#code-block("text", "-DHADOOP_USER_NAME=hdfs_user")

The #raw("hive") user generally works, since Hive is often started with the #raw("hive") user and this user has access to the Hive warehouse.

#anchor("ref-hdfs-security-impersonation")

=== HDFS impersonation

HDFS impersonation is enabled by adding #raw("hive.hdfs.impersonation.enabled=true") to the catalog properties file. With this configuration HDFS, Trino can impersonate the end user who is running the query. This can be used with HDFS permissions and ACLs to provide additional security for data. HDFS permissions and ACLs are explained in the #link("https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-hdfs/HdfsPermissionsGuide.html")[HDFS Permissions Guide].

To use impersonation, the Hadoop cluster must be configured to allow the user or principal that Trino is running as to impersonate the users who log in to Trino. Impersonation in Hadoop is configured in the file #raw("core-site.xml"). A complete description of the configuration options is available in the #link("https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/Superusers.html#Configurations")[Hadoop documentation].

In the case of a user running a query from the #link(label("doc-client-cli"))[command line interface], the end user is the username associated with the Trino CLI process or argument to the optional #raw("--user") option.

#anchor("ref-hdfs-security-kerberos")

=== HDFS Kerberos authentication

To use Trino with a Hadoop cluster that uses Kerberos authentication, you must configure the catalog in the catalog properties file to work with two services on the Hadoop cluster:

- The Hive metastore Thrift service, see #link(label("ref-hive-thrift-metastore-authentication"))[Metastores]
- The Hadoop Distributed File System \(HDFS\), see examples in #link(label("ref-hive-security-kerberos"))[HDFS file system support] or #link(label("ref-hive-security-kerberos-impersonation"))[HDFS file system support]

Both setups require that Kerberos is configured on each Trino node. Access to the Trino coordinator must be secured, for example using Kerberos or password authentication, when using Kerberos authentication to Hadoop services. Failure to secure access to the Trino coordinator could result in unauthorized access to sensitive data on the Hadoop cluster. Refer to #link(label("doc-security"))[Security] for further information, and specifically consider configuring #link(label("doc-security-kerberos"))[Kerberos authentication].

#note[
If your #raw("krb5.conf") location is different from #raw("/etc/krb5.conf") you must set it explicitly using the #raw("java.security.krb5.conf") JVM property in the #raw("jvm.config") file. For example, #raw("-Djava.security.krb5.conf=/example/path/krb5.conf").
]

#anchor("ref-hive-security-additional-keytab")

==== Keytab files

Keytab files are needed for Kerberos authentication and contain encryption keys that are used to authenticate principals to the Kerberos KDC. These encryption keys must be stored securely; you must take the same precautions to protect them that you take to protect ssh private keys.

In particular, access to keytab files must be limited to only the accounts that must use them to authenticate. In practice, this is the user that the Trino process runs as. The ownership and permissions on keytab files must be set to prevent other users from reading or modifying the files.

Keytab files must be distributed to every node running Trino, and  must have the correct permissions on every node after distributing them.

== Security configuration examples

The following sections describe the configuration properties and values needed for the various authentication configurations with HDFS.

#anchor("ref-hive-security-simple")

=== Default #raw("NONE") authentication without impersonation

#code-block("text", "hive.hdfs.authentication.type=NONE")

The default authentication type for HDFS is #raw("NONE"). When the authentication type is #raw("NONE"), Trino connects to HDFS using Hadoop's simple authentication mechanism. Kerberos is not used.

#anchor("ref-hive-security-simple-impersonation")

=== #raw("NONE") authentication with impersonation

#code-block("text", "hive.hdfs.authentication.type=NONE
hive.hdfs.impersonation.enabled=true")

When using #raw("NONE") authentication with impersonation, Trino impersonates the user who is running the query when accessing HDFS. The user Trino is running as must be allowed to impersonate this user, as discussed in the section #link(label("ref-hdfs-security-impersonation"))[HDFS file system support]. Kerberos is not used.

#anchor("ref-hive-security-kerberos")

=== #raw("KERBEROS") authentication without impersonation

#code-block("text", "hive.hdfs.authentication.type=KERBEROS
hive.hdfs.trino.principal=trino@EXAMPLE.COM
hive.hdfs.trino.keytab=/etc/trino/trino.keytab")

When the authentication type is #raw("KERBEROS"), Trino accesses HDFS as the principal specified by the #raw("hive.hdfs.trino.principal") property. Trino authenticates this principal using the keytab specified by the #raw("hive.hdfs.trino.keytab") keytab.

#anchor("ref-hive-security-kerberos-impersonation")

=== #raw("KERBEROS") authentication with impersonation

#code-block("text", "hive.hdfs.authentication.type=KERBEROS
hive.hdfs.impersonation.enabled=true
hive.hdfs.trino.principal=trino@EXAMPLE.COM
hive.hdfs.trino.keytab=/etc/trino/trino.keytab")

When using #raw("KERBEROS") authentication with impersonation, Trino impersonates the user who is running the query when accessing HDFS. The principal specified by the #raw("hive.hdfs.trino.principal") property must be allowed to impersonate the current Trino user, as discussed in the section #link(label("ref-hdfs-security-impersonation"))[HDFS file system support]. Trino authenticates #raw("hive.hdfs.trino.principal") using the keytab specified by #raw("hive.hdfs.trino.keytab").
