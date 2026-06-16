#import "/lib/trino-docs.typ": *

#anchor("doc-object-storage-file-system-azure")
= Azure Storage file system support

Trino includes a native implementation to access #link("https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-overview#about-azure-data-lake-storage-gen2")[Azure Data Lake Storage Gen2] with a catalog using the Delta Lake, Hive, Hudi, or Iceberg connectors.

Enable the native implementation with #raw("fs.azure.enabled=true") in your catalog properties file. Additionally, the Azure storage account must have hierarchical namespace enabled.

== General configuration

Use the following properties to configure general aspects of Azure Storage file system support:

#list-table((
  ([Property], [Description],),
  ([#raw("fs.azure.enabled")], [Activate the native implementation for Azure Storage support. Defaults to #raw("false"). Set to #raw("true") to use Azure Storage and enable all other properties.],),
  ([#raw("azure.auth-type")], [Authentication type to use for Azure Storage access. Defaults to #raw("DEFAULT") which loads from environment variables if configured or #link(label("ref-azure-user-assigned-managed-identity-authentication"))[Azure Storage file system support]. Use #raw("ACCESS_KEY") for #link(label("ref-azure-access-key-authentication"))[Azure Storage file system support] or and #raw("OAUTH") for #link(label("ref-azure-oauth-authentication"))[Azure Storage file system support].],),
  ([#raw("azure.endpoint")], [Hostname suffix of the Azure storage endpoint. Defaults to #raw("core.windows.net") for the global Azure cloud. Use #raw("core.usgovcloudapi.net") for the Azure US Government cloud, #raw("core.cloudapi.de") for the Azure Germany cloud, or #raw("core.chinacloudapi.cn") for the Azure China cloud.],),
  ([#raw("azure.read-block-size")], [#link(label("ref-prop-type-data-size"))[Data size] for blocks during read operations. Defaults to #raw("4MB").],),
  ([#raw("azure.write-block-size")], [#link(label("ref-prop-type-data-size"))[Data size] for blocks during write operations. Defaults to #raw("4MB").],),
  ([#raw("azure.max-write-concurrency")], [Maximum number of concurrent write operations. Defaults to 8.],),
  ([#raw("azure.max-single-upload-size")], [#link(label("ref-prop-type-data-size"))[Data size] Defaults to #raw("4MB").],),
  ([#raw("azure.max-http-requests")], [Maximum #link(label("ref-prop-type-integer"))[integer] number of concurrent HTTP requests to Azure from every node. Defaults to double the number of processors on the node. Minimum #raw("1"). Use this property to reduce the number of requests when you encounter rate limiting issues.],),
  ([#raw("azure.connection-pool-max-idle-time")], [#link(label("ref-prop-type-duration"))[Duration] that a connection can remain idle in the connection pool before it is closed. Defaults to #raw("5m").],),
  ([#raw("azure.http-request-timeout")], [#link(label("ref-prop-type-duration"))[Duration] for HTTP request timeouts, including the time taken by the Azure SDK to retry a request. Defaults to #raw("10m").],),
  ([#raw("azure.application-id")], [Specify the application identifier appended to the #raw("User-Agent") header for all requests sent to Azure Storage. Defaults to #raw("Trino").],),
  ([#raw("azure.multipart-write-enabled")], [Enable multipart writes for large files. Defaults to #raw("false").],)
), header-rows: 1)

#anchor("ref-azure-user-assigned-managed-identity-authentication")

== User-assigned managed identity authentication

Use the following properties to configure #link("https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/")[user-assigned managed identity] authentication to Azure Storage:

#list-table((
  ([Property], [Description],),
  ([#raw("azure.auth-type")], [Must be set to #raw("DEFAULT").],),
  ([#raw("azure.user-assigned-managed-identity.client-id")], [Specifies the client ID of user-assigned managed identity.],),
  ([#raw("azure.user-assigned-managed-identity.resource-id")], [Specifies the resource ID of user-assigned managed identity.],)
), header-rows: 1)

Only one of #raw("azure.user-assigned-managed-identity.client-id") or #raw("azure.user-assigned-managed-identity.resource-id") can be specified.

#anchor("ref-azure-access-key-authentication")

== Access key authentication

Use the following properties to configure access key authentication to Azure Storage:

#list-table((
  ([Property], [Description],),
  ([#raw("azure.auth-type")], [Must be set to #raw("ACCESS_KEY").],),
  ([#raw("azure.access-key")], [The decrypted access key for the Azure Storage account. Requires authentication type #raw("ACCESSS_KEY").],)
), header-rows: 1)

#anchor("ref-azure-oauth-authentication")

== OAuth 2.0 authentication

Use the following properties to configure OAuth 2.0 authentication to Azure Storage:

#list-table((
  ([Property], [Description],),
  ([#raw("azure.auth-type")], [Must be set to #raw("OAUTH").],),
  ([#raw("azure.oauth.tenant-id")], [Tenant ID for Azure authentication.],),
  ([#raw("azure.oauth.endpoint")], [The endpoint URL for OAuth 2.0 authentication.],),
  ([#raw("azure.oauth.client-id")], [The OAuth 2.0 service principal's client or application ID.],),
  ([#raw("azure.oauth.secret")], [A OAuth 2.0 client secret for the service principal.],)
), header-rows: 1)

== Access multiple storage accounts

To allow Trino to access multiple Azure storage accounts from a single catalog configuration, you can use #link(label("ref-azure-oauth-authentication"))[Azure Storage file system support] with an Azure service principal. The following steps describe how to create a service principal in Azure and assign an IAM role granting access to the storage accounts:

- Create a service principal in Azure Active Directory using Azure #strong[App Registrations] and save the client secret.
- Assign access to the storage accounts from the account's #strong[Access Control \(IAM\)] section. You can add #strong[Role Assignments] and select appropriate roles, such as #strong[Storage Blob Data Contributor].
- Assign access using the option #strong[User, group, or service principal] and select the service principal created. Save to finalize the role assignment.

Once you create the service principal and configure the storage accounts use the #strong[Client ID], #strong[Secret] and #strong[Tenant ID] values from the application registration, to configure the catalog using properties from #link(label("ref-azure-oauth-authentication"))[Azure Storage file system support].

#anchor("ref-fs-legacy-azure-migration")

== Migration from legacy Azure Storage file system

Previous Trino releases included a legacy Azure Storage file system implementation used by catalogs configured with #raw("fs.hadoop.enabled") and #raw("hive.azure.*") properties. That legacy support has been removed. Use the native Azure file system implementation.

To migrate a catalog to use the native file system implementation for Azure, make the following edits to your catalog configuration:

+ Add the #raw("fs.azure.enabled=true") catalog configuration property.
+ If your catalog enabled #raw("fs.hadoop.enabled") only for legacy Azure Storage access, remove that property.
+ Configure the #raw("azure.auth-type") catalog configuration property.
+ Refer to the following table to rename your existing legacy catalog configuration properties to the corresponding native configuration properties. Supported configuration values are identical unless otherwise noted.

#list-table((
  ([Legacy property], [Native property], [Notes],),
  ([#raw("hive.azure.abfs-access-key")], [#raw("azure.access-key")], [],),
  ([#raw("hive.azure.abfs.oauth.endpoint")], [#raw("azure.oauth.endpoint")], [Also see #raw("azure.oauth.tenant-id") in #link(label("ref-azure-oauth-authentication"))[Azure Storage file system support].],),
  ([#raw("hive.azure.abfs.oauth.client-id")], [#raw("azure.oauth.client-id")], [],),
  ([#raw("hive.azure.abfs.oauth.secret")], [#raw("azure.oauth.secret")], [],),
  ([#raw("hive.azure.abfs.oauth2.passthrough")], [#raw("azure.use-oauth-passthrough-token")], [],)
), header-rows: 1)

+ Remove the following legacy configuration properties if they exist in your catalog configuration:
  
  - #raw("hive.azure.abfs-storage-account")
  - #raw("hive.azure.wasb-access-key")
  - #raw("hive.azure.wasb-storage-account")
