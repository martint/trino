#import "/lib/trino-docs.typ": *

#anchor("doc-develop-system-access-control")
= System access control

Trino separates the concept of the principal who authenticates to the coordinator from the username that is responsible for running queries. When running the Trino CLI, for example, the Trino username can be specified using the #raw("--user") option.

By default, the Trino coordinator allows any principal to run queries as any Trino user. In a secure environment, this is probably not desirable behavior and likely requires customization.

== Implementation

#raw("SystemAccessControlFactory") is responsible for creating a #raw("SystemAccessControl") instance. It also defines a #raw("SystemAccessControl") name which is used by the administrator in a Trino configuration.

#raw("SystemAccessControl") implementations have several responsibilities:

- Verifying whether or not a given principal is authorized to execute queries as a specific user.
- Determining whether or not a given user can alter values for a given system property.
- Performing access checks across all catalogs. These access checks happen before any connector specific checks and thus can deny permissions that would otherwise be allowed by #raw("ConnectorAccessControl").

The implementation of #raw("SystemAccessControl") and #raw("SystemAccessControlFactory") must be wrapped as a plugin and installed on the Trino cluster.

== Configuration

After a plugin that implements #raw("SystemAccessControl") and #raw("SystemAccessControlFactory") has been installed on the coordinator, it is configured using the file\(s\) specified by the #raw("access-control.config-files") property \(the default is a single #raw("etc/access-control.properties") file\). All the properties other than #raw("access-control.name") are specific to the #raw("SystemAccessControl") implementation.

The #raw("access-control.name") property is used by Trino to find a registered #raw("SystemAccessControlFactory") based on the name returned by #raw("SystemAccessControlFactory.getName()"). The remaining properties are passed as a map to #raw("SystemAccessControlFactory.create()").

Example configuration file:

#code-block("text", "access-control.name=custom-access-control
custom-property1=custom-value1
custom-property2=custom-value2")
