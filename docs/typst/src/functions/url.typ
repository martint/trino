#import "/lib/trino-docs.typ": *

#anchor("doc-functions-url")
= URL functions

== Extraction functions

The URL extraction functions extract components from HTTP URLs \(or any valid URIs conforming to #link("https://www.rfc-editor.org/rfc/rfc2396")[RFC 2396]\). The following syntax is supported:

#code-block("text", "[protocol:][//host[:port]][path][?query][#fragment]")

The extracted components do not contain URI syntax separators such as #raw(":") or #raw("?").

#function-def("fn-url-extract-fragment", "url_extract_fragment(url)", "varchar")[
Returns the fragment identifier from #raw("url").
]

#function-def("fn-url-extract-host", "url_extract_host(url)", "varchar")[
Returns the host from #raw("url").
]

#function-def("fn-url-extract-parameter", "url_extract_parameter(url, name)", "varchar")[
Returns the value of the first query string parameter named #raw("name") from #raw("url"). Parameter extraction is handled in the typical manner as specified by #link("https://www.rfc-editor.org/rfc/rfc1866#section-8.2.1")[RFC 1866\#section-8.2.1].
]

#function-def("fn-url-extract-path", "url_extract_path(url)", "varchar")[
Returns the path from #raw("url").
]

#function-def("fn-url-extract-port", "url_extract_port(url)", "bigint")[
Returns the port number from #raw("url").
]

#function-def("fn-url-extract-protocol", "url_extract_protocol(url)", "varchar")[
Returns the protocol from #raw("url"):

#code-block(none, "SELECT url_extract_protocol('http://localhost:8080/req_path');
-- http

SELECT url_extract_protocol('https://127.0.0.1:8080/req_path');
-- https

SELECT url_extract_protocol('ftp://path/file');
-- ftp")
]

#function-def("fn-url-extract-query", "url_extract_query(url)", "varchar")[
Returns the query string from #raw("url").
]

== Encoding functions

#function-def("fn-url-encode", "url_encode(value)", "varchar")[
Escapes #raw("value") by encoding it so that it can be safely included in URL query parameter names and values:

- Alphanumeric characters are not encoded.
- The characters #raw("."), #raw("-"), #raw("*") and #raw("_") are not encoded.
- The ASCII space character is encoded as #raw("+").
- All other characters are converted to UTF-8 and the bytes are encoded as the string #raw("%XX") where #raw("XX") is the uppercase hexadecimal value of the UTF-8 byte.
]

#function-def("fn-url-decode", "url_decode(value)", "varchar")[
Unescapes the URL encoded #raw("value"). This function is the inverse of #link(label("fn-url-encode"), raw("url_encode")).
]
