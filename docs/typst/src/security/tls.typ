#import "/lib/trino-docs.typ": *

#anchor("doc-security-tls")
= TLS and HTTPS

Trino runs with no security by default. This allows you to connect to the server using URLs that specify the HTTP protocol when using the Trino #link(label("doc-client-cli"))[CLI], the #link(label("doc-admin-web-interface"))[Web UI], or other clients.

This topic describes how to configure your Trino server to use TLS to require clients to use the HTTPS connection protocol. All authentication technologies supported by Trino require configuring TLS as the foundational layer.

#important[
This page discusses only how to prepare the Trino server for secure client connections from outside the Trino cluster to its coordinator.
]

See the #link(label("doc-glossary"))[Glossary] to clarify unfamiliar terms.

#anchor("ref-tls-version-and-ciphers")

== Supported standards

When configured to use TLS, the Trino server responds to client connections using TLS 1.2 and TLS 1.3 certificates. The server rejects TLS 1.1, TLS 1.0, and all SSL format certificates.

The Trino server does not specify a set of supported ciphers, instead deferring to the defaults set by the JVM version in use. The documentation for Java 25 lists its #link("https://docs.oracle.com/en/java/javase/25/security/oracle-providers.html#GUID-7093246A-31A3-4304-AC5F-5FB6400405E2__SUNJSSE_CIPHER_SUITES")[supported cipher suites].

Run the following two-line code on the same JVM from the same vendor as configured on the coordinator to determine that JVM's default cipher list.

#code-block("shell", "echo \"java.util.Arrays.asList(((javax.net.ssl.SSLServerSocketFactory) \\
javax.net.ssl.SSLServerSocketFactory.getDefault()).getSupportedCipherSuites()).forEach(System.out::println)\" | jshell -")

The default Trino server specifies a set of regular expressions that exclude older cipher suites that do not support forward secrecy \(FS\).

Use the #raw("http-server.https.included-cipher") property to specify a comma-separated list of ciphers in preferred use order. If one of your preferred selections is a non-FS cipher, you must also set the #raw("http-server.https.excluded-cipher") property to an empty list to override the default exclusions. For example:

#code-block("text", "http-server.https.included-cipher=TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_128_CBC_SHA256
http-server.https.excluded-cipher=")

Specifying a different cipher suite is a complex issue that should only be considered in conjunction with your organization's security managers. Using a different suite may require downloading and installing a different SunJCE implementation package. Some locales may have export restrictions on cipher suites. See the discussion in Java documentation that begins with #link("https://docs.oracle.com/en/java/javase/25/security/java-secure-socket-extension-jsse-reference-guide.html#GUID-316FB978-7588-442E-B829-B4973DB3B584")[Customizing the Encryption Algorithm Providers].

#note[
If you manage the coordinator's direct TLS implementation, monitor the CPU usage on the Trino coordinator after enabling HTTPS. Java prefers the more CPU-intensive cipher suites, if you allow it to choose from a big list of ciphers. If the CPU usage is unacceptably high after enabling HTTPS, you can configure Java to use specific cipher suites as described in this section.

However, best practice is to instead use an external load balancer, as discussed next.
]

== Approaches

To configure Trino with TLS support, consider two alternative paths:

- Use the #link(label("ref-https-load-balancer"))[load balancer or proxy] at your site or cloud environment to terminate TLS\/HTTPS. This approach is the simplest and strongly preferred solution.
- Secure the Trino #link(label("ref-https-secure-directly"))[server directly]. This requires you to obtain a valid certificate, and add it to the Trino coordinator's configuration.

#anchor("ref-https-load-balancer")

== Use a load balancer to terminate TLS\/HTTPS

Your site or cloud environment may already have a load balancer or proxy server configured and running with a valid, globally trusted TLS certificate. In this case, you can work with your network administrators to set up your Trino server behind the load balancer. The load balancer or proxy server accepts TLS connections and forwards them to the Trino coordinator, which typically runs with default HTTP configuration on the default port, 8080.

When a load balancer accepts a TLS encrypted connection, it adds a #link("https://developer.mozilla.org/docs/Web/HTTP/Proxy_servers_and_tunneling#forwarding_client_information_through_proxies")[forwarded] HTTP header to the request, such as #raw("X-Forwarded-Proto: https").

This tells the Trino coordinator to process the connection as if a TLS connection has already been successfully negotiated for it. This is why you do not need to configure #raw("http-server.https.enabled=true") for a coordinator behind a load balancer.

However, to enable processing of such forwarded headers, the server's #link(label("ref-config-properties"))[config properties file] #emph[must] include the following:

#code-block("text", "http-server.process-forwarded=true")

More information about HTTP server configuration is available in #link(label("doc-admin-properties-http-server"))[HTTP server properties].

This completes any necessary configuration for using HTTPS with a load balancer. Client tools can access Trino with the URL exposed by the load balancer.

#anchor("ref-https-secure-directly")

== Secure Trino directly

Instead of the preferred mechanism of using an #link(label("ref-https-load-balancer"))[external load balancer], you can secure the Trino coordinator itself. This requires you to obtain and install a TLS certificate, and configure Trino to use it for client connections.

=== Add a TLS certificate

Obtain a TLS certificate file for use with your Trino server. Consider the following types of certificates:

- #strong[Globally trusted certificates] — A certificate that is automatically trusted by all browsers and clients. This is the easiest type to use because you do not need to configure clients. Obtain a certificate of this type from:
  
  - A commercial certificate vendor
  - Your cloud infrastructure provider
  - A domain name registrar, such as Verisign or GoDaddy
  - A free certificate generator, such as #link("https://letsencrypt.org/")[letsencrypt.org] or #link("https://www.sslforfree.com/")[sslforfree.com]
- #strong[Corporate trusted certificates] — A certificate trusted by browsers and clients in your organization. Typically, a site's IT department runs a local certificate authority and preconfigures clients and servers to trust this CA.
- #strong[Generated self-signed certificates] — A certificate generated just for Trino that is not automatically trusted by any client. Before using, make sure you understand the #link(label("ref-self-signed-limits"))[limitations of self-signed certificates].

The most convenient option and strongly recommended option is a globally trusted certificate. It may require a little more work up front, but it is worth it to not have to configure every single client.

=== Keys and certificates

Trino can read certificates and private keys encoded in PEM encoded PKCS \#1, PEM encoded PKCS \#8, PKCS \#12, and the legacy Java KeyStore \(JKS\) format. Certificates and private keys encoded in a binary format such as DER must be converted.

Make sure you obtain a certificate that is validated by a recognized certificate authority.

=== Inspect received certificates

Before installing your certificate, inspect and validate the received key and certificate files to make sure they reference the correct information to access your Trino server. Much unnecessary debugging time is saved by taking the time to validate your certificates before proceeding to configure the server.

Inspect PEM-encoded files as described in #link(label("doc-security-inspect-pem"))[Inspect PEM files].

Inspect PKCS \# 12 and JKS keystores as described in #link(label("doc-security-inspect-jks"))[Inspect JKS files].

=== Invalid certificates

If your certificate does not pass validation, or does not show the expected information on inspection, contact the group or vendor who provided it for a replacement.

#anchor("ref-cert-placement")

=== Place the certificate file

There are no location requirements for a certificate file as long as:

- The file can be read by the Trino coordinator server process.
- The location is secure from copying or tampering by malicious actors.

You can place your file in the Trino coordinator's #raw("etc") directory, which allows you to use a relative path reference in configuration files. However, this location can require you to keep track of the certificate file, and move it to a new #raw("etc") directory when you upgrade your Trino version.

#anchor("ref-configure-https")

=== Configure the coordinator

On the coordinator, add the following lines to the #link(label("ref-config-properties"))[config properties file] to enable TLS\/HTTPS support for the server.

#note[
Legacy #raw("keystore") and #raw("truststore") wording is used in property names, even when directly using PEM-encoded certificates.
]

#code-block("text", "http-server.https.enabled=true
http-server.https.port=8443
http-server.https.keystore.path=etc/clustercoord.pem")

Possible alternatives for the third line include:

#code-block("text", "http-server.https.keystore.path=etc/clustercoord.jks
http-server.https.keystore.path=/usr/local/certs/clustercoord.p12")

Relative paths are relative to the Trino server's root directory. In a #raw("tar.gz") installation, the root directory is one level above #raw("etc").

JKS keystores always require a password, while PEM files with passwords are not supported by Trino. For JKS, add the following line to the configuration:

#code-block("text", "http-server.https.keystore.key=<keystore-password>")

It is possible for a key inside a keystore to have its own password, independent of the keystore's password. In this case, specify the key's password with the following property:

#code-block("text", "http-server.https.keymanager.password=<key-password>")

When your Trino coordinator has an authenticator enabled along with HTTPS enabled, HTTP access is automatically disabled for all clients, including the #link(label("doc-admin-web-interface"))[Web UI]. Although not recommended, you can re-enable it by setting:

#code-block("text", "http-server.authentication.allow-insecure-over-http=true")

#anchor("ref-verify-tls")

=== Verify configuration

To verify TLS\/HTTPS configuration, log in to the #link(label("doc-admin-web-interface"))[Web UI], and send a query with the Trino #link(label("doc-client-cli"))[CLI].

- Connect to the Web UI from your browser using a URL that uses HTTPS, such as #raw("https://trino.example.com:8443"). Enter any username into the #raw("Username") text box, and log in to the UI. The #raw("Password") box is disabled while authentication is not configured.
- Connect with the Trino CLI using a URL that uses HTTPS, such as #raw("https://trino.example.com:8443"):

#code-block("text", "./trino --server https://trino.example.com:8443")

Send a query to test the connection:

#code-block("text", "trino> SELECT 'rocks' AS trino;

trino
-------
rocks
(1 row)

Query 20220919_113804_00017_54qfi, FINISHED, 1 node
Splits: 1 total, 1 done (100.00%)
0.12 [0 rows, 0B] [0 rows/s, 0B/s]")

#anchor("ref-self-signed-limits")

== Limitations of self-signed certificates

It is possible to generate a self-signed certificate with the #raw("openssl"), #raw("keytool"), or on Linux, #raw("certtool") commands. Self-signed certificates can be useful during development of a cluster for internal use only. We recommend never using a self-signed certificate for a production Trino server.

Self-signed certificates are not trusted by anyone. They are typically created by an administrator for expediency, because they do not require getting trust signoff from anyone.

To use a self-signed certificate while developing your cluster requires:

- distributing to every client a local truststore that validates the certificate
- configuring every client to use this certificate

However, even with this client configuration, modern browsers reject these certificates, which makes self-signed servers difficult to work with.

There is a difference between self-signed and unsigned certificates. Both types are created with the same tools, but unsigned certificates are meant to be forwarded to a CA with a Certificate Signing Request \(CSR\). The CA returns the certificate signed by the CA and now globally trusted.
