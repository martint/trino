#import "/lib/trino-docs.typ": *

#anchor("doc-security-built-in-system-access-control")
= System access control

A system access control enforces authorization at a global level, before any connector level authorization. You can use one of the built-in implementations in Trino, or provide your own by following the guidelines in #link(label("doc-develop-system-access-control"))[System access control].

To use a system access control, add an #raw("etc/access-control.properties") file with the following content and the desired system access control name on all cluster nodes:

#code-block("text", "access-control.name=allow-all")

#anchor("ref-multiple-access-control")

== Multiple access control systems

Multiple system access control implementations may be configured at once using the #raw("access-control.config-files") configuration property. It must contain a comma-separated list of the access control property files to use, rather than the default #raw("etc/access-control.properties"). Relative paths from the Trino #raw("INSTALL_PATH") or absolute paths are supported. Each system is configured in a separate configuration file.

The configured access control systems are checked until access rights are denied by a system. If no denies are issued by any system, the request is granted. Therefore all configured access control systems are used and evaluated for each request that is granted.

For example, you can combine #raw("file") access control and #raw("ranger") access control with the two separate configuration files #raw("file-based.properties") and #raw("ranger.properties").

#code-block("properties", "access-control.config-files=etc/file-based.properties,etc/ranger.properties")

#warning[
Using multiple access control systems can be very complex to configure and maintain. In addition, each system and policy within each system is evaluated for each query, which can have a considerable, negative performance impact.
]

== Available access control systems

Trino offers the following built-in system access control implementations:

#list-table((
  ([Name], [Description],),
  ([#raw("default")], [All operations are permitted, except for user impersonation and triggering #link(label("doc-admin-graceful-shutdown"))[Graceful shutdown].

This is the default access control if none are configured.],),
  ([#raw("allow-all")], [All operations are permitted.],),
  ([#raw("read-only")], [Operations that read data or metadata are permitted, but none of the operations that write data or metadata are allowed.],),
  ([#raw("file")], [Authorization rules are specified in a config file. See #link(label("doc-security-file-system-access-control"))[File-based access control].],),
  ([#raw("opa")], [Use Open Policy Agent \(OPA\) for authorization. See #link(label("doc-security-opa-access-control"))[Open Policy Agent access control].],),
  ([#raw("ranger")], [Use Apache Ranger policies for authorization. See #link(label("doc-security-ranger-access-control"))[Ranger access control].],)
), header-rows: 1)

If you want to limit access on a system level in any other way than the ones listed above, you must implement a custom #link(label("doc-develop-system-access-control"))[System access control].

Access control must be configured on the coordinator. Authorization for operations on specific worker nodes, such a triggering #link(label("doc-admin-graceful-shutdown"))[Graceful shutdown], must also be configured on all workers.

== Read only system access control

This access control allows any operation that reads data or metadata, such as #raw("SELECT") or #raw("SHOW"). Setting system level or catalog level session properties is also permitted. However, any operation that writes data or metadata, such as #raw("CREATE"), #raw("INSERT") or #raw("DELETE"), is prohibited. To use this access control, add an #raw("etc/access-control.properties") file with the following contents:

#code-block("text", "access-control.name=read-only")
