#import "/lib/trino-docs.typ": *

#anchor("doc-admin-graceful-shutdown")
= Graceful shutdown

Trino has a graceful shutdown API that can be used exclusively on workers in order to ensure that they terminate without affecting running queries, given a sufficient grace period.

You can invoke the API with a HTTP PUT request:

#code-block("bash", "# When using no authorization:
curl -v -X PUT -d '\"SHUTTING_DOWN\"' -H 'Content-type: application/json' -H 'X-Trino-User: authorizeduser' \\
    http://worker:8081/v1/info/state

# Or when using basic auth:
curl -v -X PUT -d '\"SHUTTING_DOWN\"' -H 'Content-type: application/json' -u 'authorizeduser:password' \\
    https://worker/v1/info/state")

A successful invocation is logged with a #raw("Shutdown requested") message at #raw("INFO") level in the worker server log.

Keep the following aspects in mind:

- If your cluster is secure, you need to provide a basic-authorization header, or satisfy whatever other security you have enabled.
- If you have TLS\/HTTPS enabled, you have to ensure the worker certificate is CA signed, or trusted by the server calling the shut down endpoint. Otherwise, you can make the call #raw("--insecure"), but that isn't recommended.
- The #raw("default") #link(label("doc-security-built-in-system-access-control"))[System access control] does not allow graceful shutdowns. You can use the #raw("allow-all") system access control, configure #link(label("ref-system-file-auth-system-information"))[system information rules] with the #raw("file") system access control or use Apache Ranger #link(label("doc-security-ranger-access-control"))[Ranger access control]. Note that the access control configuration must be present on all workers.
- The user must have permissions to write #emph["system information"]. In Apache Ranger this permission can be found under #emph["System Information - Write System Information"].

== Shutdown behavior

Once the API is called, the worker performs the following steps:

- Go into #raw("SHUTTING_DOWN") state.
- / Sleep for #raw("shutdown.grace-period"), which defaults to 2 minutes.: - After this, the coordinator is aware of the shutdown and stops sending tasks to the worker.
- Block until all active tasks are complete.
- Sleep for the grace period again in order to ensure the coordinator sees all tasks are complete.
- Shutdown the application.
