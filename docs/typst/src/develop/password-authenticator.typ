#import "/lib/trino-docs.typ": *

#anchor("doc-develop-password-authenticator")
= Password authenticator

Trino supports authentication with a username and password via a custom password authenticator that validates the credentials and creates a principal.

== Implementation

#raw("PasswordAuthenticatorFactory") is responsible for creating a #raw("PasswordAuthenticator") instance. It also defines the name of this authenticator which is used by the administrator in a Trino configuration.

#raw("PasswordAuthenticator") contains a single method, #raw("createAuthenticatedPrincipal()"), that validates the credential and returns a #raw("Principal"), which is then authorized by the system-access-control.

The implementation of #raw("PasswordAuthenticatorFactory") must be wrapped as a plugin and installed on the Trino cluster.

== Configuration

After a plugin that implements #raw("PasswordAuthenticatorFactory") has been installed on the coordinator, it is configured using an #raw("etc/password-authenticator.properties") file. All the properties other than #raw("password-authenticator.name") are specific to the #raw("PasswordAuthenticatorFactory") implementation.

The #raw("password-authenticator.name") property is used by Trino to find a registered #raw("PasswordAuthenticatorFactory") based on the name returned by #raw("PasswordAuthenticatorFactory.getName()"). The remaining properties are passed as a map to #raw("PasswordAuthenticatorFactory.create()").

Example configuration file:

#code-block("text", "password-authenticator.name=custom-access-control
custom-property1=custom-value1
custom-property2=custom-value2")

Additionally, the coordinator must be configured to use password authentication and have HTTPS enabled \(or HTTPS forwarding enabled\).
