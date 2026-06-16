#import "/lib/trino-docs.typ": *

#anchor("doc-admin-properties-http-client")
= HTTP client properties

HTTP client properties allow you to configure the connection from Trino to external services using HTTP.

The following properties can be used after adding the specific prefix to the property. For example, for #link(label("doc-security-oauth2"))[OAuth 2.0 authentication], you can enable HTTP for interactions with the external OAuth 2.0 provider by adding the prefix #raw("oauth2-jwk") to the #raw("http-client.connect-timeout") property, and increasing the connection timeout to ten seconds by setting the value to #raw("10"):

#code-block(none, "oauth2-jwk.http-client.connect-timeout=10s")

The following prefixes are supported:

- #raw("oauth2-jwk") for #link(label("doc-security-oauth2"))[OAuth 2.0 authentication]
- #raw("jwk") for #link(label("doc-security-jwt"))[JWT authentication]
- #raw("exchange") to configure data transfer between Trino nodes in addition to #link(label("doc-admin-properties-exchange"))[Exchange properties]

== General properties

=== #raw("http-client.connect-timeout")

- #strong[Type:] #link(label("ref-prop-type-duration"))[Properties reference]
- #strong[Default value:] #raw("5s")
- #strong[Minimum value:] #raw("0ms")

Timeout value for establishing the connection to the external service.

=== #raw("max-content-length")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[Properties reference]
- #strong[Default value:] #raw("16MB")

Maximum content size for each HTTP request and response.

=== #raw("http-client.request-timeout")

- #strong[Type:] #link(label("ref-prop-type-duration"))[Properties reference]
- #strong[Default value:] #raw("5m")
- #strong[Minimum value:] #raw("0ms")

Timeout value for the overall request.

== TLS and security properties

=== #raw("http-client.https.excluded-cipher")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

A comma-separated list of regexes for the names of cipher algorithms to exclude.

=== #raw("http-client.https.included-cipher")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

A comma-separated list of regexes for the names of the cipher algorithms to use.

=== #raw("http-client.https.hostname-verification")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]
- #strong[Default value:] #raw("true")

Verify that the server hostname matches the server DNS name in the SubjectAlternativeName \(SAN\) field of the certificate.

=== #raw("http-client.key-store-password")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

Password for the keystore.

=== #raw("http-client.key-store-path")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

File path on the server to the keystore file.

=== #raw("http-client.secure-random-algorithm")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

Set the secure random algorithm for the connection. The default varies by operating system. Algorithms are specified according to standard algorithm name documentation.

Possible types include #raw("NativePRNG"), #raw("NativePRNGBlocking"), #raw("NativePRNGNonBlocking"), #raw("PKCS11"), and #raw("SHA1PRNG").

=== #raw("http-client.trust-store-password")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

Password for the truststore.

=== #raw("http-client.trust-store-path")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

File path on the server to the truststore file.

== Proxy properties

=== #raw("http-client.http-proxy")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

Host and port for an HTTP proxy with the format #raw("example.net:8080").

=== #raw("http-client.http-proxy.user")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

Username for basic authentication with the HTTP proxy.

=== #raw("http-client.http-proxy.password")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

Password for basic authentication with the HTTP proxy.

=== #raw("http-client.http-proxy.secure")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]
- #strong[Default value:] #raw("false")

Enable HTTPS for the proxy.

=== #raw("http-client.socks-proxy")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

Host and port for a SOCKS proxy.

== Request logging

=== #raw("http-client.log.compression.enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]
- #strong[Default value:] #raw("true")

Enable log file compression. The client uses the #raw(".gz") format for log files.

=== #raw("http-client.log.enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]
- #strong[Default value:] #raw("false")

Enable logging of HTTP requests.

=== #raw("http-client.log.flush-interval")

- #strong[Type:] #link(label("ref-prop-type-duration"))[Properties reference]
- #strong[Default value:] #raw("10s")

Frequency of flushing the log data to disk.

=== #raw("http-client.log.max-history")

- #strong[Type:] #link(label("ref-prop-type-integer"))[Properties reference]
- #strong[Default value:] #raw("15")

Retention limit of log files in days. Files older than the #raw("max-history") are deleted when the HTTP client creates files for new logging periods.

=== #raw("http-client.log.max-size")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[Properties reference]
- #strong[Default value:] #raw("1GB")

Maximum total size of all log files on disk.

=== #raw("http-client.log.path")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]
- #strong[Default value:] #raw("var/log/")

Sets the path of the log files. All log files are named #raw("http-client.log"), and have the prefix of the specific HTTP client added. For example, #raw("jwk-http-client.log").

=== #raw("http-client.log.queue-size")

- #strong[Type:] #link(label("ref-prop-type-integer"))[Properties reference]
- #strong[Default value:] #raw("10000")
- #strong[Minimum value:] #raw("1")

Size of the HTTP client logging queue.
