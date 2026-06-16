#import "/lib/trino-docs.typ": *

#anchor("doc-object-storage-file-system-gcs")
= Google Cloud Storage file system support

Trino includes a native implementation to access #link("https://cloud.google.com/storage/")[Google Cloud Storage \(GCS\)] with a catalog using the Delta Lake, Hive, Hudi, or Iceberg connectors.

Enable the native implementation with #raw("fs.gcs.enabled=true") in your catalog properties file.

== General configuration

Use the following properties to configure general aspects of Google Cloud Storage file system support:

#list-table((
  ([Property], [Description],),
  ([#raw("fs.gcs.enabled")], [Activate the native implementation for Google Cloud Storage support. Defaults to #raw("false"). Set to #raw("true") to use Google Cloud Storage and enable all other properties.],),
  ([#raw("gcs.project-id")], [Identifier for the project on Google Cloud Storage.],),
  ([#raw("gcs.endpoint")], [Optional URL for the Google Cloud Storage endpoint. Configure this property if your storage is accessed using a custom URL, for example #raw("http://storage.example.com:8000").],),
  ([#raw("gcs.client.max-retries")], [Maximum number of RPC attempts. Defaults to 20.],),
  ([#raw("gcs.client.backoff-scale-factor")], [Scale factor for RPC retry delays. Defaults to 3.],),
  ([#raw("gcs.client.max-retry-time")], [Total time #link(label("ref-prop-type-duration"))[duration] limit for RPC call retries. Defaults to #raw("25s").],),
  ([#raw("gcs.client.min-backoff-delay")], [Minimum delay #link(label("ref-prop-type-duration"))[duration] between RPC retries. Defaults to #raw("10ms").],),
  ([#raw("gcs.client.max-backoff-delay")], [Maximum delay #link(label("ref-prop-type-duration"))[duration] between RPC retries. Defaults to #raw("2s").],),
  ([#raw("gcs.read-block-size")], [Minimum #link(label("ref-prop-type-data-size"))[data size] for blocks read per RPC. Defaults to #raw("2MiB"). See #raw("com.google.cloud.BaseStorageReadChannel").],),
  ([#raw("gcs.write-block-size")], [Minimum #link(label("ref-prop-type-data-size"))[data size] for blocks written per RPC. The Defaults to #raw("16MiB"). See #raw("com.google.cloud.BaseStorageWriteChannel").],),
  ([#raw("gcs.page-size")], [Maximum number of blobs to return per page. Defaults to 100.],),
  ([#raw("gcs.batch-size")], [Number of blobs to delete per batch. Defaults to 100. #link("https://cloud.google.com/storage/docs/batch")[Recommended batch size] is 100.],),
  ([#raw("gcs.application-id")], [Specify the application identifier appended to the #raw("User-Agent") header for all requests sent to Google Cloud Storage. Defaults to #raw("Trino").],)
), header-rows: 1)

== Authentication

Use one of the following properties to configure the authentication to Google Cloud Storage:

#list-table((
  ([Property], [Description],),
  ([#raw("gcs.auth-type")], [Authentication type to use for Google Cloud Storage access. Default to #raw("SERVICE_ACCOUNT"). Supported values are:

- #raw("SERVICE_ACCOUNT"): loads credentials from the environment. Either #raw("gcs.json-key") or #raw("gcs.json-key-file-path") can be set in addition to override the default credentials provider.
- #raw("ACCESS_TOKEN"): usage of client-provided OAuth 2.0 token to access Google Cloud Storage.
- #raw("APPLICATION_DEFAULT"): Attempts to obtain Google Application Default Credentials \(ADC\) from the environment. If no ADC is available, the filesystem falls back to #raw("NoCredentials.getInstance()") to explicitly indicate unauthenticated GCS access.],),
  ([#raw("gcs.json-key")], [Your Google Cloud service account key in JSON format. Not to be set together with #raw("gcs.json-key-file-path").],),
  ([#raw("gcs.json-key-file-path")], [Path to the JSON file on each node that contains your Google Cloud Platform service account key. Not to be set together with #raw("gcs.json-key").],)
), header-rows: 1)

#anchor("ref-fs-legacy-gcs-migration")

== Migration from legacy Google Cloud Storage file system

Previous Trino releases included a legacy Google Cloud Storage file system implementation used by catalogs configured with #raw("fs.hadoop.enabled") and #raw("hive.gcs.*") properties. That legacy support has been removed. Use the native Google Cloud Storage file system implementation.

To migrate a catalog to use the native file system implementation for Google Cloud Storage, make the following edits to your catalog configuration:

+ Add the #raw("fs.gcs.enabled=true") catalog configuration property.
+ If your catalog enabled #raw("fs.hadoop.enabled") only for legacy Google Cloud Storage access, remove that property.
+ Refer to the following table to rename your existing legacy catalog configuration properties to the corresponding native configuration properties. Supported configuration values are identical unless otherwise noted.

#list-table((
  ([Legacy property], [Native property], [Notes],),
  ([#raw("hive.gcs.use-access-token")], [#raw("gcs.auth-type")], [],),
  ([#raw("hive.gcs.json-key-file-path")], [#raw("gcs.json-key-file-path")], [Also see #raw("gcs.json-key") in preceding sections],)
), header-rows: 1)
