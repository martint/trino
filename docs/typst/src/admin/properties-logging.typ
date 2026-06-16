#import "/lib/trino-docs.typ": *

#anchor("doc-admin-properties-logging")
= Logging properties

== #raw("log.annotation-file")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]

An optional properties file that contains annotations to include with each log message for TCP output or file output in JSON format, defined with #raw("log.path") and #raw("log.format"). This can be used to include machine-specific or environment-specific information into logs which are centrally aggregated. The annotation values can contain references to environment variables.

#code-block("properties", "environment=production
host=${ENV:HOSTNAME}")

== #raw("log.format")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Default value:] #raw("TEXT")

The file format for log records. Can be set to either #raw("TEXT") or #raw("JSON"). When set to #raw("JSON"), the log record is formatted as a JSON object, one record per line. Any newlines in the field values, such as exception stack traces, are escaped as normal in the JSON object. This allows for capturing and indexing exceptions as singular fields in a logging search system.

== #raw("log.console-format")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Default value:] #raw("TEXT")

The format for log records written to the console output, set to either #raw("TEXT") or #raw("JSON"). When set to #raw("JSON"), the log record is formatted as a JSON object, one record per line. Any newlines in the field values, such as exception stack traces, are escaped as normal in the JSON object. This allows for capturing and indexing exceptions as singular fields in a logging search system when using console output and capturing it, as commonly configured in containers.

== #raw("log.path")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]

The path to the log file used by Trino. The path is relative to the data directory, configured to #raw("var/log/server.log") by the launcher script as detailed in #link(label("ref-running-trino"))[running-trino]. Alternatively, you can write logs to separate the process \(typically running next to Trino as a sidecar process\) via the TCP protocol by using a log path of the format #raw("tcp://host:port").

== #raw("log.max-size")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[prop-type-data-size]
- #strong[Default value:] #raw("100MB")

The maximum file size for the general application log file.

== #raw("log.max-total-size")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[prop-type-data-size]
- #strong[Default value:] #raw("1GB")

The maximum file size for all general application log files combined.

== #raw("log.compression")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Default value:] #raw("GZIP")

The compression format for rotated log files. Can be set to either #raw("GZIP") or #raw("NONE"). When set to #raw("NONE"), compression is disabled.

== #raw("http-server.log.enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("true")

Flag to enable or disable logging for the HTTP server.

== #raw("http-server.log.compression.enabled")

- #strong[Type:] #link(label("ref-prop-type-boolean"))[prop-type-boolean]
- #strong[Default value:] #raw("true")

Flag to enable or disable compression of the log files of the HTTP server.

== #raw("http-server.log.path")

- #strong[Type:] #link(label("ref-prop-type-string"))[prop-type-string]
- #strong[Default value:] #raw("var/log/http-request.log")

The path to the log file used by the HTTP server. The path is relative to the data directory, configured by the launcher script as detailed in #link(label("ref-running-trino"))[running-trino].

== #raw("http-server.log.max-history")

- #strong[Type:] #link(label("ref-prop-type-integer"))[prop-type-integer]
- #strong[Default value:] #raw("15")

The maximum number of log files for the HTTP server to use, before log rotation replaces old content.

== #raw("http-server.log.max-size")

- #strong[Type:] #link(label("ref-prop-type-data-size"))[prop-type-data-size]
- #strong[Default value:] #raw("unlimited")

The maximum file size for the log file of the HTTP server. Defaults to #raw("unlimited"), setting a #link(label("ref-prop-type-data-size"))[prop-type-data-size] value limits the file size to that value.
