#import "/lib/trino-docs.typ": *

#anchor("doc-develop-group-provider")
= Group provider

Trino can map usernames onto groups for easier access control management. This mapping is performed by a #raw("GroupProvider") implementation.

== Implementation

#raw("GroupProviderFactory") is responsible for creating a #raw("GroupProvider") instance. It also defines the name of the group provider as used in the configuration file.

#raw("GroupProvider") contains a one method, #raw("getGroups(String user)") which returns a #raw("Set<String>") of group names. This set of group names becomes part of the #raw("Identity") and #raw("ConnectorIdentity") objects representing the user, and can then be used by system-access-control.

The implementation of #raw("GroupProvider") and its corresponding #raw("GroupProviderFactory") must be wrapped as a Trino plugin and installed on the cluster.

== Configuration

After a plugin that implements #raw("GroupProviderFactory") has been installed on the coordinator, it is configured using an #raw("etc/group-provider.properties") file. All the properties other than #raw("group-provider.name") are specific to the #raw("GroupProviderFactory") implementation.

The #raw("group-provider.name") property is used by Trino to find a registered #raw("GroupProviderFactory") based on the name returned by #raw("GroupProviderFactory.getName()"). The remaining properties are passed as a map to #raw("GroupProviderFactory.create(Map<String, String>)").

Example configuration file:

#code-block("text", "group-provider.name=custom-group-provider
custom-property1=custom-value1
custom-property2=custom-value2")

With that file in place, Trino will attempt user group name resolution, and will be able to use the group names while evaluating access control rules.
