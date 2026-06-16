#import "/lib/trino-docs.typ": *

#anchor("doc-admin-properties")
= Properties reference

This section describes the most important configuration properties and \(where applicable\) their corresponding #link(label("ref-session-properties-definition"))[session properties], that may be used to tune Trino or alter its behavior when required. Unless specified otherwise, configuration properties must be set on the coordinator and all worker nodes.

The following pages are not a complete list of all configuration and session properties available in Trino, and do not include any connector-specific catalog configuration properties. For more information on catalog configuration properties, refer to the connector documentation.

- #link(label("doc-admin-properties-general"))[General properties]
- #link(label("doc-admin-properties-client-protocol"))[Client protocol properties]
- #link(label("doc-admin-properties-http-server"))[HTTP server properties]
- #link(label("doc-admin-properties-resource-management"))[Resource management properties]
- #link(label("doc-admin-properties-query-management"))[Query management properties]
- #link(label("doc-admin-properties-catalog"))[Catalog management properties]
- #link(label("doc-admin-properties-sql-environment"))[SQL environment properties]
- #link(label("doc-admin-properties-spilling"))[Spilling properties]
- #link(label("doc-admin-properties-exchange"))[Exchange properties]
- #link(label("doc-admin-properties-task"))[Task properties]
- #link(label("doc-admin-properties-write-partitioning"))[Write partitioning properties]
- #link(label("doc-admin-properties-writer-scaling"))[Writer scaling properties]
- #link(label("doc-admin-properties-node-scheduler"))[Node scheduler properties]
- #link(label("doc-admin-properties-optimizer"))[Optimizer properties]
- #link(label("doc-admin-properties-logging"))[Logging properties]
- #link(label("doc-admin-properties-web-interface"))[Web UI properties]
- #link(label("doc-admin-properties-regexp-function"))[Regular expression function properties]
- #link(label("doc-admin-properties-http-client"))[HTTP client properties]

== Property value types

Trino configuration properties support different value types with their own allowed values and syntax. Additional limitations apply on a per-property basis, and disallowed values result in a validation error.

#anchor("ref-prop-type-boolean")

=== #raw("boolean")

The properties of type #raw("boolean") support two values, #raw("true") or #raw("false").

#anchor("ref-prop-type-data-size")

=== #raw("data size")

The properties of type #raw("data size") support values that describe an amount of data, measured in byte-based units. These units are incremented in multiples of 1024, so one megabyte is 1024 kilobytes, one kilobyte is 1024 bytes, and so on. For example, the value #raw("6GB") describes six gigabytes, which is \(6 \* 1024 \* 1024 \* 1024\) = 6442450944 bytes.

The #raw("data size") type supports the following units:

- #raw("B"): Bytes
- #raw("kB"): Kilobytes
- #raw("MB"): Megabytes
- #raw("GB"): Gigabytes
- #raw("TB"): Terabytes
- #raw("PB"): Petabytes

#anchor("ref-prop-type-double")

=== #raw("double")

The properties of type #raw("double") support numerical values including decimals, such as #raw("1.6"). #raw("double") type values can be negative, if supported by the specific property.

#anchor("ref-prop-type-duration")

=== #raw("duration")

The properties of type #raw("duration") support values describing an amount of time, using the syntax of a non-negative number followed by a time unit. For example, the value #raw("7m") describes seven minutes.

The #raw("duration") type supports the following units:

- #raw("ns"): Nanoseconds
- #raw("us"): Microseconds
- #raw("ms"): Milliseconds
- #raw("s"): Seconds
- #raw("m"): Minutes
- #raw("h"): Hours
- #raw("d"): Days

A duration of #raw("0") is treated as zero regardless of the unit that follows. For example, #raw("0s") and #raw("0m") both mean the same thing.

Properties of type #raw("duration") also support decimal values, such as #raw("2.25d"). These are handled as a fractional value of the specified unit. For example, the value #raw("1.5m") equals one and a half minutes, or 90 seconds.

#anchor("ref-prop-type-heap-size")

=== #raw("heap size")

Properties of type #raw("heap size") support values that specify an amount of heap memory. These values can be provided in the same format as the #raw("data size") property, or as #raw("double") values followed by a #raw("%") suffix. The #raw("%") suffix indicates a percentage of the maximum heap memory available on the node. The minimum allowed value is #raw("1B"), and the maximum is #raw("100%"), which corresponds to the maximum heap memory available on the node.

#anchor("ref-prop-type-integer")

=== #raw("integer")

The properties of type #raw("integer") support whole numeric values, such as #raw("5") and #raw("1000"). Negative values are supported as well, for example #raw("-7"). #raw("integer") type values must be whole numbers, decimal values such as #raw("2.5") are not supported.

Some #raw("integer") type properties enforce their own minimum and maximum values.

#anchor("ref-prop-type-string")

=== #raw("string")

The properties of type #raw("string") support a set of values that consist of a sequence of characters. Allowed values are defined on a property-by-property basis, refer to the specific property for its supported and default values.
