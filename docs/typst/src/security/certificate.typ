#import "/lib/trino-docs.typ": *

#anchor("doc-security-certificate")
= Certificate authentication

You can configure Trino to support client-provided certificates validated by the Trino server on initial connection.

#important[
This authentication method is only provided to support sites that have an absolute requirement for client authentication #emph[and already have] client certificates for each client. Sites in this category have an existing PKI infrastructure, possibly including an onsite Certificate Authority \(CA\).

This feature is not appropriate for sites that need to generate a set of client certificates in order to use this authentication type. Consider instead using another #link(label("ref-cl-access-auth"))[authentication type].
]

Using TLS and #link(label("doc-security-internal-communication"))[a configured shared secret] is required for certificate authentication.

== Using certificate authentication

All clients connecting with TLS\/HTTPS go through the following initial steps:

+ The client attempts to contact the coordinator.
+ The coordinator returns its certificate to the client.
+ The client validates the server's certificate using the client's trust store.

A cluster with certificate authentication enabled goes through the following additional steps:

+ The coordinator asks the client for its certificate.
+ The client responds with its certificate.
+ The coordinator verifies the client's certificate, using the coordinator's trust store.

Several rules emerge from these steps:

- Trust stores used by clients must include the certificate of the signer of the coordinator's certificate.
- Trust stores used by coordinators must include the certificate of the signer of client certificates.
- The trust stores used by the coordinator and clients do not need to be the same.
- The certificate that verifies the coordinator does not need to be the same as the certificate verifying clients.

Trino validates certificates based on the distinguished name \(DN\) from the X.509 #raw("Subject") field. You can use #link(label("doc-security-user-mapping"))[user mapping] to map the subject DN to a Trino username.

There are three levels of client certificate support possible. From the point of view of the server:

- The server does not require a certificate from clients.
- The server asks for a certificate from clients, but allows connection without one.
- The server must have a certificate from clients to allow connection.

Trino's client certificate support is the middle type. It asks for a certificate but allows connection if another authentication method passes.

== Certificate authentication configuration

Enable certificate authentication by setting the Certificate authentication type in #link(label("ref-config-properties"))[etc\/config.properties]:

#code-block("properties", "http-server.authentication.type=CERTIFICATE")

You can specify certificate authentication along with another authentication method, such as #raw("PASSWORD"). In this case, authentication is performed in the order of entries, and the first successful authentication results in access. For example, the following setting shows the use of two authentication types:

#code-block("properties", "http-server.authentication.type=CERTIFICATE,PASSWORD")

The following configuration properties are also available:

#list-table((
  ([Property name], [Description],),
  ([#raw("http-server.authentication.certificate.user-mapping.pattern")], [A regular expression pattern to #link(label("doc-security-user-mapping"))[map all user names] for this authentication type to the format expected by Trino.],),
  ([#raw("http-server.authentication.certificate.user-mapping.file")], [The path to a JSON file that contains a set of #link(label("doc-security-user-mapping"))[user mapping rules] for this authentication type.],)
), header-rows: 1, title: "Configuration properties")

== Use certificate authentication with clients

When using the Trino #link(label("doc-client-cli"))[CLI], specify the #raw("--keystore-path") and #raw("--keystore-password") options as described in #link(label("ref-cli-certificate-auth"))[cli-certificate-auth].

When using the Trino #link(label("doc-client-jdbc"))[JDBC driver] to connect to a cluster with certificate authentication enabled, use the #raw("SSLKeyStoreType") and #raw("SSLKeyStorePassword") #link(label("ref-jdbc-parameter-reference"))[parameters] to specify the path to the client's certificate and its password, if any.
