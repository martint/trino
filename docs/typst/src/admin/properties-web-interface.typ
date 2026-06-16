#import "/lib/trino-docs.typ": *

#anchor("doc-admin-properties-web-interface")
= Web UI properties

The following properties can be used to configure the web-interface.

== #raw("web-ui.authentication.type")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Allowed values:] #raw("FORM"), #raw("FIXED"), #raw("CERTIFICATE"), #raw("KERBEROS"), #raw("JWT"), #raw("OAUTH2")
- #strong[Default value:] #raw("FORM")

The authentication mechanism to allow user access to the Web UI. See #link(label("ref-web-ui-authentication"))[Web UI Authentication].

== #raw("web-ui.enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("true")

This property controls whether or not the #link(label("doc-admin-web-interface"))[Web UI] is available.

== #raw("web-ui.preview.enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("false")

This property controls whether or not the #link(label("doc-admin-preview-web-interface"))[Preview Web UI] is available.

== #raw("web-ui.shared-secret")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Default value:] randomly generated unless set

The shared secret is used to generate authentication cookies for users of the Web UI. If not set to a static value, any coordinator restart generates a new random value, which in turn invalidates the session of any currently logged in Web UI user.

== #raw("web-ui.session-timeout")

- #strong[Type:] #link(label("ref-prop-type-duration"))[prop-type-duration]
- #strong[Default value:] #raw("1d")

The duration how long a user can be logged into the Web UI, before the session times out, which forces an automatic log-out.

== #raw("web-ui.user")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Default value:] None

The username automatically used for authentication to the Web UI with the #raw("fixed") authentication type. See #link(label("ref-web-ui-authentication"))[Web UI Authentication].
