#import "/lib/trino-docs.typ": *

#anchor("doc-admin-properties-http-server")
= HTTP server properties

HTTP server properties allow you to configure the HTTP server of Trino that handles #link(label("doc-security"))[Security] including #link(label("doc-security-internal-communication"))[Secure internal communication],  and serves the #link(label("doc-admin-web-interface"))[Web UI] and the #link(label("doc-develop-client-protocol"))[client API].

== General

#anchor("ref-http-server-process-forwarded")

=== #raw("http-server.process-forwarded")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]
- #strong[Default value:] #raw("false")

Enable treating forwarded HTTPS requests over HTTP as secure. Requires the #link("https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Forwarded-For#see_also")[#raw("X-Forwarded") headers] to be set to #raw("HTTPS") on forwarded requests. This is commonly performed by a load balancer that terminates HTTPS to HTTP. Set to #raw("true") when using such a load balancer in front of Trino or #link("https://trinodb.github.io/trino-gateway/")[Trino Gateway]. Find more details in #link(label("ref-https-load-balancer"))[TLS and HTTPS].

== HTTP and HTTPS

=== #raw("http-server.http.port")

- #strong[Type:] #link(label("ref-prop-type-integer"))[Properties reference]
- #strong[Default value:] #raw("8080")

Specify the HTTP port for the HTTP server.

=== #raw("http-server.https.enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]
- #strong[Default value:] #raw("false")

Enable #link(label("doc-security-tls"))[TLS and HTTPS].

=== #raw("http-server.https.port")

- #strong[Type:] #link(label("ref-prop-type-integer"))[Properties reference]
- #strong[Default value:] #raw("8443")

Specify the HTTPS port for the HTTP server.

=== #raw("http-server.https.included-cipher") and #raw("http-server.https.excluded-cipher")

Optional configuration for ciphers to use TLS, find details in #link(label("ref-tls-version-and-ciphers"))[TLS and HTTPS].

=== #raw("http-server.https.keystore.path")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

The location of the PEM or Java keystore file used to enable #link(label("doc-security-tls"))[TLS and HTTPS].

=== #raw("http-server.https.keystore.key")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

The password for the PEM or Java keystore.

=== #raw("http-server.https.truststore.path")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]
- #strong[Default value:] #raw("false")

The location of the optional PEM or Java truststore file for additional certificate authorities. Find details in #link(label("doc-security-tls"))[TLS and HTTPS].

=== #raw("http-server.https.truststore.key")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]
- #strong[Default value:] #raw("false")

The password for the optional PEM or Java truststore.

=== #raw("http-server.https.keymanager.password")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

Password for a key within a keystore, when a different password is configured for the specific key. Find details in #link(label("doc-security-tls"))[TLS and HTTPS].

=== #raw("http-server.https.secure-random-algorithm")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

Optional name of the algorithm to generate secure random values for #link(label("ref-internal-performance"))[internal communication].

=== #raw("http-server.https.ssl-session-timeout")

- #strong[Type:] #link(label("ref-prop-type-duration"))[Properties reference]
- #strong[Default value:] #raw("4h")

Time duration for a valid TLS client session.

=== #raw("http-server.https.ssl-session-cache-size")

- #strong[Type:] #link(label("ref-prop-type-integer"))[Properties reference]
- #strong[Default value:] #raw("10000")

Maximum number of SSL session cache entries.

=== #raw("http-server.https.ssl-context.refresh-time")

- #strong[Type:] #link(label("ref-prop-type-duration"))[Properties reference]
- #strong[Default value:] #raw("1m")

Time between reloading default certificates.

== Authentication

=== #raw("http-server.authentication.type")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

Configures the ordered list of enabled #link(label("doc-security-authentication-types"))[authentication types].

All authentication requires secure connections using #link(label("doc-security-tls"))[TLS and HTTPS] or #link(label("ref-http-server-process-forwarded"))[process forwarding enabled], and #link(label("doc-security-internal-communication"))[a configured shared secret].

=== #raw("http-server.authentication.allow-insecure-over-http")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]

Enable HTTP when any authentication is active. Defaults to #raw("true"), but is automatically set to #raw("false") with active authentication. Overriding the value to #raw("true") can be useful for testing, but is not secure. More details in #link(label("doc-security-tls"))[TLS and HTTPS].

=== #raw("http-server.authentication.certificate.*")

Configuration properties for #link(label("doc-security-certificate"))[Certificate authentication].

=== #raw("http-server.authentication.jwt.*")

Configuration properties for #link(label("doc-security-jwt"))[JWT authentication].

=== #raw("http-server.authentication.krb5.*")

Configuration properties for #link(label("doc-security-kerberos"))[Kerberos authentication].

=== #raw("http-server.authentication.oauth2.*")

Configuration properties for #link(label("doc-security-oauth2"))[OAuth 2.0 authentication].

=== #raw("http-server.authentication.password.*")

Configuration properties for the #raw("PASSWORD") authentication types #link(label("doc-security-ldap"))[LDAP authentication], #link(label("doc-security-password-file"))[Password file authentication], and #link(label("doc-security-salesforce"))[Salesforce authentication].

== Logging

=== #raw("http-server.log.*")

Configuration properties for #link(label("doc-admin-properties-logging"))[Logging properties].

\(props-internal-communication\)

== Internal communication

The following properties are used for configuring the #link(label("doc-security-internal-communication"))[internal communication] between all #link(label("ref-trino-concept-node"))[nodes] of a Trino cluster.

=== #raw("internal-communication.shared-secret")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

The string to use as secret that only the coordinators and workers in a specific cluster share and use to authenticate within the cluster. See #link(label("ref-internal-secret"))[Secure internal communication] for details.

=== #raw("internal-communication.http2.enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]
- #strong[Default value:] #raw("true")

Enable use of the HTTP\/2 protocol for internal communication for enhanced scalability compared to HTTP\/1.1. Only turn this feature off if you encounter issues with HTTP\/2 usage within the cluster in your deployment.

=== #raw("internal-communication.https.required")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[Properties reference]
- #strong[Default value:] #raw("false")

Enable the use of #link(label("ref-internal-tls"))[SSL\/TLS for all internal communication].
