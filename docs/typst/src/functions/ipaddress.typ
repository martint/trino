#import "/lib/trino-docs.typ": *

#anchor("doc-functions-ipaddress")
= IP Address Functions

#anchor("ref-ip-address-contains")

#function-def("fn-contains-2", "contains(network, address)", "boolean", ref: false)[
Returns true if the #raw("address") exists in the CIDR #raw("network"):

#code-block(none, "SELECT contains('10.0.0.0/8', IPADDRESS '10.255.255.255'); -- true
SELECT contains('10.0.0.0/8', IPADDRESS '11.255.255.255'); -- false

SELECT contains('2001:0db8:0:0:0:ff00:0042:8329/128', IPADDRESS '2001:0db8:0:0:0:ff00:0042:8329'); -- true
SELECT contains('2001:0db8:0:0:0:ff00:0042:8329/128', IPADDRESS '2001:0db8:0:0:0:ff00:0042:8328'); -- false")
]
