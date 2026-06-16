#import "/lib/trino-docs.typ": *

#anchor("doc-develop-header-authenticator")
= Header authenticator

Trino supports header authentication over TLS via a custom header authenticator that extracts the principal from a predefined header\(s\), performs any validation it needs and creates an authenticated principal.

== Implementation

#raw("HeaderAuthenticatorFactory") is responsible for creating a #raw("HeaderAuthenticator") instance. It also defines the name of this authenticator which is used by the administrator in a Trino configuration.

#raw("HeaderAuthenticator") contains a single method, #raw("createAuthenticatedPrincipal()"), which validates the request headers wrapped by the Headers interface; has the method getHeader\(String name\) and returns a #raw("Principal"), which is then authorized by the system-access-control.

The implementation of #raw("HeaderAuthenticatorFactory") must be wrapped as a plugin and installed on the Trino cluster.

== Configuration

After a plugin that implements #raw("HeaderAuthenticatorFactory") has been installed on the coordinator, it is configured using an #raw("etc/header-authenticator.properties") file. All the properties other than #raw("header-authenticator.name") are specific to the #raw("HeaderAuthenticatorFactory") implementation.

The #raw("header-authenticator.name") property is used by Trino to find a registered #raw("HeaderAuthenticatorFactory") based on the name returned by #raw("HeaderAuthenticatorFactory.getName()"). The remaining properties are passed as a map to #raw("HeaderAuthenticatorFactory.create()").

Example configuration file:

#code-block("none", "header-authenticator.name=custom
custom-property1=custom-value1
custom-property2=custom-value2")

Additionally, the coordinator must be configured to use header authentication and have HTTPS enabled \(or HTTPS forwarding enabled\).
