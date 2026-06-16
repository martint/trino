#import "/lib/trino-docs.typ": *

#anchor("doc-object-storage-file-system-s3")
= S3 file system support

Trino includes a native implementation to access #link("https://aws.amazon.com/s3/")[Amazon S3] and compatible storage systems with a catalog using the Delta Lake, Hive, Hudi, or Iceberg connectors. While Trino is designed to support S3-compatible storage systems, only AWS S3 and MinIO are tested for compatibility. For other storage systems, perform your own testing and consult your vendor for more information.

Enable the native implementation with #raw("fs.s3.enabled=true") in your catalog properties file.

== General configuration

Use the following properties to configure general aspects of S3 file system support:

#list-table((
  ([Property], [Description],),
  ([#raw("fs.s3.enabled")], [Activate the native implementation for S3 storage support. Defaults to #raw("false"). Set to #raw("true") to use S3 and enable all other properties.],),
  ([#raw("s3.endpoint")], [S3 service endpoint URL to communicate with.],),
  ([#raw("s3.region")], [S3 region to communicate with.],),
  ([#raw("s3.cross-region-access")], [Enable cross region access. Defaults to #raw("false").],),
  ([#raw("s3.path-style-access")], [Use path-style access for all requests to S3],),
  ([#raw("s3.storage-class")], [S3 storage class to use while writing data. Defaults to #raw("STANDARD"). Other allowed values are: #raw("STANDARD_IA"), #raw("INTELLIGENT_TIERING"), #raw("REDUCED_REDUNDANCY"), #raw("ONEZONE_IA"), #raw("GLACIER"), #raw("DEEP_ARCHIVE"), #raw("OUTPOSTS"), #raw("GLACIER_IR"), #raw("SNOW"), #raw("EXPRESS_ONEZONE").],),
  ([#raw("s3.signer-type")], [AWS signing protocol to use for authenticating S3 requests. Supported values are: #raw("AwsS3V4Signer"), #raw("Aws4Signer"), #raw("AsyncAws4Signer"), #raw("Aws4UnsignedPayloadSigner"), #raw("EventStreamAws4Signer").],),
  ([#raw("s3.canned-acl")], [#link("https://docs.aws.amazon.com/AmazonS3/latest/userguide/acl-overview.html#canned-acl")[Canned ACL] to use when uploading files to S3. Defaults to #raw("NONE"), which has the same effect as #raw("PRIVATE"). If the files are to be uploaded to an S3 bucket owned by a different AWS user, the canned ACL may be set to one of the following: #raw("PRIVATE"), #raw("PUBLIC_READ"), #raw("PUBLIC_READ_WRITE"), #raw("AUTHENTICATED_READ"), #raw("BUCKET_OWNER_READ"), or #raw("BUCKET_OWNER_FULL_CONTROL").],),
  ([#raw("s3.sse.type")], [Set the type of S3 server-side encryption \(SSE\) to use. Defaults to #raw("NONE") for no encryption. Other valid values are #raw("S3") for encryption by S3 managed keys, #raw("KMS") for encryption with a key from the AWS Key Management Service \(KMS\), and #raw("CUSTOMER") for encryption with a customer-provided key from #raw("s3.sse.customer-key"). Note that S3 automatically uses SSE so #raw("NONE") and #raw("S3") are equivalent. S3-compatible systems might behave differently.],),
  ([#raw("s3.sse.kms-key-id")], [The identifier of a key in KMS to use for SSE.],),
  ([#raw("s3.sse.customer-key")], [The 256-bit, base64-encoded AES-256 encryption key to encrypt or decrypt data from S3 when using the SSE-C mode for SSE with #raw("s3.sse.type") set to #raw("CUSTOMER").],),
  ([#raw("s3.streaming.part-size")], [Part size for S3 streaming upload. Values between #raw("5MB") and #raw("256MB") are valid. Defaults to #raw("32MB").],),
  ([#raw("s3.requester-pays")], [Switch to activate billing transfer cost to the requester. Defaults to #raw("false").],),
  ([#raw("s3.max-connections")], [Maximum number of connections to S3.  Defaults to #raw("500").],),
  ([#raw("s3.connection-ttl")], [Maximum time #link(label("ref-prop-type-duration"))[duration] allowed to reuse connections in the connection pool before being replaced.],),
  ([#raw("s3.connection-max-idle-time")], [Maximum time #link(label("ref-prop-type-duration"))[duration] allowed for connections to remain idle in the connection pool before being closed.],),
  ([#raw("s3.socket-connect-timeout")], [Maximum time #link(label("ref-prop-type-duration"))[duration] allowed for socket connection requests to complete before timing out.],),
  ([#raw("s3.socket-timeout")], [Maximum time #link(label("ref-prop-type-duration"))[duration] for socket read\/write operations before timing out.],),
  ([#raw("s3.tcp-keep-alive")], [Enable TCP keep alive on created connections. Defaults to #raw("false").],),
  ([#raw("s3.http-proxy")], [URL of a HTTP proxy server to use for connecting to S3.],),
  ([#raw("s3.http-proxy.secure")], [Set to #raw("true") to enable HTTPS for the proxy server.],),
  ([#raw("s3.http-proxy.username")], [Proxy username to use if connecting through a proxy server.],),
  ([#raw("s3.http-proxy.password")], [Proxy password to use if connecting through a proxy server.],),
  ([#raw("s3.http-proxy.non-proxy-hosts")], [Hosts list to access without going through the proxy server.],),
  ([#raw("s3.http-proxy.preemptive-basic-auth")], [Whether to attempt to authenticate preemptively against proxy server when using base authorization, defaults to #raw("false").],),
  ([#raw("s3.retry-mode")], [Specifies how the AWS SDK attempts retries. Default value is #raw("LEGACY"). Other allowed values are #raw("STANDARD") and #raw("ADAPTIVE"). The #raw("STANDARD") mode includes a standard set of errors that are retried. #raw("ADAPTIVE") mode includes the functionality of #raw("STANDARD") mode with automatic client-side throttling.],),
  ([#raw("s3.max-error-retries")], [Specifies maximum number of retries the client will make on errors. Defaults to #raw("20").],),
  ([#raw("s3.use-web-identity-token-credentials-provider")], [Set to #raw("true") to only use the web identity token credentials provider, instead of the default providers chain. This can be useful when running Trino on Amazon EKS and using #link("https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html")[IAM roles for service accounts \(IRSA\)] Defaults to #raw("false").],),
  ([#raw("s3.application-id")], [Specify the application identifier appended to the #raw("User-Agent") header for all requests sent to S3. Defaults to #raw("Trino").],)
), header-rows: 1)

== Authentication

Use the following properties to configure the authentication to S3 with access and secret keys, STS, or an IAM role:

#list-table((
  ([Property], [Description],),
  ([#raw("s3.aws-access-key")], [AWS access key to use for authentication.],),
  ([#raw("s3.aws-secret-key")], [AWS secret key to use for authentication.],),
  ([#raw("s3.sts.endpoint")], [The endpoint URL of the AWS Security Token Service to use for authenticating to S3.],),
  ([#raw("s3.sts.region")], [AWS region of the STS service.],),
  ([#raw("s3.iam-role")], [ARN of an IAM role to assume when connecting to S3.],),
  ([#raw("s3.role-session-name")], [Role session name to use when connecting to S3. Defaults to #raw("trino-filesystem").],),
  ([#raw("s3.external-id")], [External ID for the IAM role trust policy when connecting to S3.],)
), header-rows: 1)

== Security mapping

Trino supports flexible security mapping for S3, allowing for separate credentials or IAM roles for specific users or S3 locations. The IAM role for a specific query can be selected from a list of allowed roles by providing it as an #emph[extra credential].

Each security mapping entry may specify one or more match criteria. If multiple criteria are specified, all criteria must match. The following match criteria are available:

- #raw("user"): Regular expression to match against username. Example: #raw("alice|bob")
- #raw("group"): Regular expression to match against any of the groups that the user belongs to. Example: #raw("finance|sales")
- #raw("prefix"): S3 URL prefix. You can specify an entire bucket or a path within a bucket. The URL must start with #raw("s3://") but also matches for #raw("s3a") or #raw("s3n"). Example: #raw("s3://bucket-name/abc/xyz/")

The security mapping must provide one or more configuration settings:

- #raw("accessKey") and #raw("secretKey"): AWS access key and secret key. This overrides any globally configured credentials, such as access key or instance credentials.
- #raw("iamRole"): IAM role to use if no user provided role is specified as an extra credential. This overrides any globally configured IAM role. This role is allowed to be specified as an extra credential, although specifying it explicitly has no effect.
- #raw("roleSessionName"): Optional role session name to use with #raw("iamRole"). This can only be used when #raw("iamRole") is specified. If #raw("roleSessionName") includes the string #raw("${USER}"), then the #raw("${USER}") portion of the string is replaced with the current session's username. If #raw("roleSessionName") is not specified, it defaults to #raw("trino-session").
- #raw("allowedIamRoles"): IAM roles that are allowed to be specified as an extra credential. This is useful because a particular AWS account may have permissions to use many roles, but a specific user should only be allowed to use a subset of those roles.
- #raw("kmsKeyId"): ID of KMS-managed key to be used for client-side encryption.
- #raw("allowedKmsKeyIds"): KMS-managed key IDs that are allowed to be specified as an extra credential. If list contains #raw("*"), then any key can be specified via extra credential.
- #raw("sseCustomerKey"): The customer provided key \(SSE-C\) for server-side encryption.
- #raw("allowedSseCustomerKey"): The SSE-C keys that are allowed to be specified as an extra credential. If list contains #raw("*"), then any key can be specified via extra credential.
- #raw("endpoint"): The S3 storage endpoint server. This optional property can be used to override S3 endpoints on a per-bucket basis.
- #raw("region"): The S3 region to connect to. This optional property can be used to override S3 regions on a per-bucket basis.

The security mapping entries are processed in the order listed in the JSON configuration. Therefore, specific mappings must be specified before less specific mappings. For example, the mapping list might have URL prefix #raw("s3://abc/xyz/") followed by #raw("s3://abc/") to allow different configuration for a specific path within a bucket than for other paths within the bucket. You can specify the default configuration by not including any match criteria for the last entry in the list.

In addition to the preceding rules, the default mapping can contain the optional #raw("useClusterDefault") boolean property set to #raw("true") to use the default S3 configuration. It cannot be used with any other configuration settings.

If no mapping entry matches and no default is configured, access is denied.

The configuration JSON is read from a file via #raw("s3.security-mapping.config-file") or from an HTTP endpoint via #raw("s3.security-mapping.config-uri").

Example JSON configuration:

#code-block("json", "{
  \"mappings\": [
    {
      \"prefix\": \"s3://bucket-name/abc/\",
      \"iamRole\": \"arn:aws:iam::123456789101:role/test_path\"
    },
    {
      \"user\": \"bob|charlie\",
      \"iamRole\": \"arn:aws:iam::123456789101:role/test_default\",
      \"allowedIamRoles\": [
        \"arn:aws:iam::123456789101:role/test1\",
        \"arn:aws:iam::123456789101:role/test2\",
        \"arn:aws:iam::123456789101:role/test3\"
      ]
    },
    {
      \"prefix\": \"s3://special-bucket/\",
      \"accessKey\": \"AKIAxxxaccess\",
      \"secretKey\": \"iXbXxxxsecret\"
    },
    {
      \"prefix\": \"s3://regional-bucket/\",
      \"iamRole\": \"arn:aws:iam::123456789101:role/regional-user\",
      \"endpoint\": \"https://bucket.vpce-1a2b3c4d-5e6f.s3.us-east-1.vpce.amazonaws.com\",
      \"region\": \"us-east-1\"
    },
    {
      \"prefix\": \"s3://encrypted-bucket/\",
      \"kmsKeyId\": \"kmsKey_10\"
    },
    {
      \"user\": \"test.*\",
      \"iamRole\": \"arn:aws:iam::123456789101:role/test_users\"
    },
    {
      \"group\": \"finance\",
      \"iamRole\": \"arn:aws:iam::123456789101:role/finance_users\"
    },
    {
      \"iamRole\": \"arn:aws:iam::123456789101:role/default\"
    }
  ]
}")

#list-table((
  ([Property name], [Description],),
  ([#raw("s3.security-mapping.enabled")], [Activate the security mapping feature. Defaults to #raw("false"). Must be set to #raw("true") for all other properties be used.],),
  ([#raw("s3.security-mapping.config-file")], [Path to the JSON configuration file containing security mappings.],),
  ([#raw("s3.security-mapping.config-uri")], [HTTP endpoint URI containing security mappings.],),
  ([#raw("s3.security-mapping.json-pointer")], [A JSON pointer \(RFC 6901\) to mappings inside the JSON retrieved from the configuration file or HTTP endpoint. The default is the root of the document.],),
  ([#raw("s3.security-mapping.iam-role-credential-name")], [The name of the #emph[extra credential] used to provide the IAM role.],),
  ([#raw("s3.security-mapping.kms-key-id-credential-name")], [The name of the #emph[extra credential] used to provide the KMS-managed key ID.],),
  ([#raw("s3.security-mapping.sse-customer-key-credential-name")], [The name of the #emph[extra credential] used to provide the server-side encryption with customer-provided keys \(SSE-C\).],),
  ([#raw("s3.security-mapping.refresh-period")], [How often to refresh the security mapping configuration, specified as a #link(label("ref-prop-type-duration"))[prop-type-duration]. By default, the configuration is not refreshed.],),
  ([#raw("s3.security-mapping.colon-replacement")], [The character or characters to be used instead of a colon character when specifying an IAM role name as an extra credential. Any instances of this replacement value in the extra credential value are converted to a colon. Choose a value not used in any of your IAM ARNs.],)
), header-rows: 1, title: "Security mapping properties")

#anchor("ref-fs-legacy-s3-migration")

== Migration from legacy S3 file system

Previous Trino releases included a legacy Amazon S3 file system implementation used by catalogs configured with #raw("fs.hadoop.enabled") and #raw("hive.s3.*") properties. That legacy support has been removed. Use the native S3 file system implementation.

To migrate a catalog to use the native file system implementation for S3, make the following edits to your catalog configuration:

+ Add the #raw("fs.s3.enabled=true") catalog configuration property.
+ If your catalog enabled #raw("fs.hadoop.enabled") only for legacy S3 access, remove that property.
+ Refer to the following table to rename your existing legacy catalog configuration properties to the corresponding native configuration properties. Supported configuration values are identical unless otherwise noted.

#list-table((
  ([Legacy property], [Native property], [Notes],),
  ([#raw("hive.s3.aws-access-key")], [#raw("s3.aws-access-key")], [],),
  ([#raw("hive.s3.aws-secret-key")], [#raw("s3.aws-secret-key")], [],),
  ([#raw("hive.s3.iam-role")], [#raw("s3.iam-role")], [Also see #raw("s3.role-session-name") in preceding sections for more role configuration options.],),
  ([#raw("hive.s3.external-id")], [#raw("s3.external-id")], [],),
  ([#raw("hive.s3.endpoint")], [#raw("s3.endpoint")], [Add the #raw("https://") prefix to make the value a correct URL.],),
  ([#raw("hive.s3.region")], [#raw("s3.region")], [],),
  ([#raw("hive.s3.sse.enabled")], [None], [#raw("s3.sse.type") set to the default value of #raw("NONE") is equivalent to #raw("hive.s3.sse.enabled=false").],),
  ([#raw("hive.s3.sse.type")], [#raw("s3.sse.type")], [],),
  ([#raw("hive.s3.sse.kms-key-id")], [#raw("s3.sse.kms-key-id")], [],),
  ([#raw("hive.s3.upload-acl-type")], [#raw("s3.canned-acl")], [See preceding sections for supported values.],),
  ([#raw("hive.s3.streaming.part-size")], [#raw("s3.streaming.part-size")], [],),
  ([#raw("hive.s3.proxy.host"), #raw("hive.s3.proxy.port")], [#raw("s3.http-proxy")], [Specify the host and port in one URL, for example #raw("localhost:8888").],),
  ([#raw("hive.s3.proxy.protocol")], [#raw("s3.http-proxy.secure")], [Set to #raw("TRUE") to enable HTTPS.],),
  ([#raw("hive.s3.proxy.non-proxy-hosts")], [#raw("s3.http-proxy.non-proxy-hosts")], [],),
  ([#raw("hive.s3.proxy.username")], [#raw("s3.http-proxy.username")], [],),
  ([#raw("hive.s3.proxy.password")], [#raw("s3.http-proxy.password")], [],),
  ([#raw("hive.s3.proxy.preemptive-basic-auth")], [#raw("s3.http-proxy.preemptive-basic-auth")], [],),
  ([#raw("hive.s3.sts.endpoint")], [#raw("s3.sts.endpoint")], [],),
  ([#raw("hive.s3.sts.region")], [#raw("s3.sts.region")], [],),
  ([#raw("hive.s3.max-error-retries")], [#raw("s3.max-error-retries")], [Also see #raw("s3.retry-mode") in preceding sections for more retry behavior configuration options.],),
  ([#raw("hive.s3.connect-timeout")], [#raw("s3.socket-connect-timeout")], [],),
  ([#raw("hive.s3.connect-ttl")], [#raw("s3.connection-ttl")], [Also see #raw("s3.connection-max-idle-time") in preceding section for more connection keep-alive options.],),
  ([#raw("hive.s3.socket-timeout")], [#raw("s3.socket-timeout")], [Also see #raw("s3.tcp-keep-alive") in preceding sections for more socket connection keep-alive options.],),
  ([#raw("hive.s3.max-connections")], [#raw("s3.max-connections")], [],),
  ([#raw("hive.s3.path-style-access")], [#raw("s3.path-style-access")], [],),
  ([#raw("hive.s3.signer-type")], [#raw("s3.signer-type")], [],)
), header-rows: 1)

+ Remove the following legacy configuration properties if they exist in your catalog configuration:
  
  - #raw("hive.s3.storage-class")
  - #raw("hive.s3.signer-class")
  - #raw("hive.s3.staging-directory")
  - #raw("hive.s3.pin-client-to-current-region")
  - #raw("hive.s3.ssl.enabled")
  - #raw("hive.s3.sse.enabled")
  - #raw("hive.s3.kms-key-id")
  - #raw("hive.s3.encryption-materials-provider")
  - #raw("hive.s3.streaming.enabled")
  - #raw("hive.s3.max-client-retries")
  - #raw("hive.s3.max-backoff-time")
  - #raw("hive.s3.max-retry-time")
  - #raw("hive.s3.multipart.min-file-size")
  - #raw("hive.s3.multipart.min-part-size")
  - #raw("hive.s3-file-system-type")
  - #raw("hive.s3.user-agent-prefix")
