#import "/lib/trino-docs.typ": *

#anchor("doc-develop-certificate-authenticator")
= Certificate authenticator

Trino supports TLS-based authentication with X509 certificates via a custom certificate authenticator that extracts the principal from a client certificate.

== Implementation

#raw("CertificateAuthenticatorFactory") is responsible for creating a #raw("CertificateAuthenticator") instance. It also defines the name of this authenticator which is used by the administrator in a Trino configuration.

#raw("CertificateAuthenticator") contains a single method, #raw("authenticate()"), which authenticates the client certificate and returns a #raw("Principal"), which is then authorized by the system-access-control.

The implementation of #raw("CertificateAuthenticatorFactory") must be wrapped as a plugin and installed on the Trino cluster.

== Configuration

After a plugin that implements #raw("CertificateAuthenticatorFactory") has been installed on the coordinator, it is configured using an #raw("etc/certificate-authenticator.properties") file. All the properties other than #raw("certificate-authenticator.name") are specific to the #raw("CertificateAuthenticatorFactory") implementation.

The #raw("certificate-authenticator.name") property is used by Trino to find a registered #raw("CertificateAuthenticatorFactory") based on the name returned by #raw("CertificateAuthenticatorFactory.getName()"). The remaining properties are passed as a map to #raw("CertificateAuthenticatorFactory.create()").

Example configuration file:

#code-block("text", "certificate-authenticator.name=custom
custom-property1=custom-value1
custom-property2=custom-value2")

Additionally, the coordinator must be configured to use certificate authentication and have HTTPS enabled \(or HTTPS forwarding enabled\).
