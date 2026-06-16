#import "/lib/trino-docs.typ": *

#anchor("doc-functions-binary")
= Binary functions and operators

== Binary operators

The #raw("||") operator performs concatenation.

== Binary functions

#function-def("fn-concat-2", "concat(binary1, ..., binaryN)", "varbinary", ref: false)[
Returns the concatenation of #raw("binary1"), #raw("binary2"), #raw("..."), #raw("binaryN"). This function provides the same functionality as the SQL-standard concatenation operator \(#raw("||")\).
]

#function-def("fn-length", "length(binary)", "bigint")[
Returns the length of #raw("binary") in bytes.
]

#function-def("fn-lpad", "lpad(binary, size, padbinary)", "varbinary")[
Left pads #raw("binary") to #raw("size") bytes with #raw("padbinary"). If #raw("size") is less than the length of #raw("binary"), the result is truncated to #raw("size") characters. #raw("size") must not be negative and #raw("padbinary") must be non-empty.
]

#function-def("fn-rpad", "rpad(binary, size, padbinary)", "varbinary")[
Right pads #raw("binary") to #raw("size") bytes with #raw("padbinary"). If #raw("size") is less than the length of #raw("binary"), the result is truncated to #raw("size") characters. #raw("size") must not be negative and #raw("padbinary") must be non-empty.
]

#function-def("fn-substr", "substr(binary, start)", "varbinary")[
Returns the rest of #raw("binary") from the starting position #raw("start"), measured in bytes. Positions start with #raw("1"). A negative starting position is interpreted as being relative to the end of the string.
]

#function-def("fn-substr-2", "substr(binary, start, length)", "varbinary", ref: false)[
Returns a substring from #raw("binary") of length #raw("length") from the starting position #raw("start"), measured in bytes. Positions start with #raw("1"). A negative starting position is interpreted as being relative to the end of the string.
]

#anchor("ref-function-reverse-varbinary")

#function-def("fn-reverse-2", "reverse(binary)", "varbinary", ref: false)[
Returns #raw("binary") with the bytes in reverse order.
]

== Base64 encoding functions

The Base64 functions implement the encoding specified in #link("https://www.rfc-editor.org/rfc/rfc4648")[RFC 4648].

#function-def("fn-from-base64", "from_base64(string)", "varbinary")[
Decodes binary data from the base64 encoded #raw("string").
]

#function-def("fn-to-base64", "to_base64(binary)", "varchar")[
Encodes #raw("binary") into a base64 string representation.
]

#function-def("fn-from-base64url", "from_base64url(string)", "varbinary")[
Decodes binary data from the base64 encoded #raw("string") using the URL safe alphabet.
]

#function-def("fn-to-base64url", "to_base64url(binary)", "varchar")[
Encodes #raw("binary") into a base64 string representation using the URL safe alphabet.
]

#function-def("fn-from-base32", "from_base32(string)", "varbinary")[
Decodes binary data from the base32 encoded #raw("string").
]

#function-def("fn-to-base32", "to_base32(binary)", "varchar")[
Encodes #raw("binary") into a base32 string representation.
]

== Hex encoding functions

#function-def("fn-from-hex", "from_hex(string)", "varbinary")[
Decodes binary data from the hex encoded #raw("string").
]

#function-def("fn-to-hex", "to_hex(binary)", "varchar")[
Encodes #raw("binary") into a hex string representation.
]

== Integer encoding functions

#function-def("fn-from-big-endian-32", "from_big_endian_32(binary)", "integer")[
Decodes the 32-bit two's complement big-endian #raw("binary"). The input must be exactly 4 bytes.
]

#function-def("fn-to-big-endian-32", "to_big_endian_32(integer)", "varbinary")[
Encodes #raw("integer") into a 32-bit two's complement big-endian format.
]

#function-def("fn-from-big-endian-64", "from_big_endian_64(binary)", "bigint")[
Decodes the 64-bit two's complement big-endian #raw("binary"). The input must be exactly 8 bytes.
]

#function-def("fn-to-big-endian-64", "to_big_endian_64(bigint)", "varbinary")[
Encodes #raw("bigint") into a 64-bit two's complement big-endian format.
]

== Floating-point encoding functions

#function-def("fn-from-ieee754-32", "from_ieee754_32(binary)", "real")[
Decodes the 32-bit big-endian #raw("binary") in IEEE 754 single-precision floating-point format. The input must be exactly 4 bytes.
]

#function-def("fn-to-ieee754-32", "to_ieee754_32(real)", "varbinary")[
Encodes #raw("real") into a 32-bit big-endian binary according to IEEE 754 single-precision floating-point format.
]

#function-def("fn-from-ieee754-64", "from_ieee754_64(binary)", "double")[
Decodes the 64-bit big-endian #raw("binary") in IEEE 754 double-precision floating-point format. The input must be exactly 8 bytes.
]

#function-def("fn-to-ieee754-64", "to_ieee754_64(double)", "varbinary")[
Encodes #raw("double") into a 64-bit big-endian binary according to IEEE 754 double-precision floating-point format.
]

== Hashing functions

#function-def("fn-crc32", "crc32(binary)", "bigint")[
Computes the CRC-32 of #raw("binary"). For general purpose hashing, use #link(label("fn-xxhash64"), raw("xxhash64")), as it is much faster and produces a better quality hash.
]

#function-def("fn-md5", "md5(binary)", "varbinary")[
Computes the MD5 hash of #raw("binary").
]

#function-def("fn-sha1", "sha1(binary)", "varbinary")[
Computes the SHA1 hash of #raw("binary").
]

#function-def("fn-sha256", "sha256(binary)", "varbinary")[
Computes the SHA256 hash of #raw("binary").
]

#function-def("fn-sha512", "sha512(binary)", "varbinary")[
Computes the SHA512 hash of #raw("binary").
]

#function-def("fn-spooky-hash-v2-32", "spooky_hash_v2_32(binary)", "varbinary")[
Computes the 32-bit SpookyHashV2 hash of #raw("binary").
]

#function-def("fn-spooky-hash-v2-64", "spooky_hash_v2_64(binary)", "varbinary")[
Computes the 64-bit SpookyHashV2 hash of #raw("binary").
]

#function-def("fn-xxhash64", "xxhash64(binary)", "varbinary")[
Computes the xxHash64 hash of #raw("binary").
]

#function-def("fn-murmur3", "murmur3(binary)", "varbinary")[
Computes the 128-bit #link("https://wikipedia.org/wiki/MurmurHash")[MurmurHash3] hash of #raw("binary").

#code-block("sql", "SELECT murmur3(from_base64('aaaaaa'));
-- ba 58 55 63 55 69 b4 2f 49 20 37 2c a0 e3 96 ef")
]

== HMAC functions

#function-def("fn-hmac-md5", "hmac_md5(binary, key)", "varbinary")[
Computes HMAC with MD5 of #raw("binary") with the given #raw("key").
]

#function-def("fn-hmac-sha1", "hmac_sha1(binary, key)", "varbinary")[
Computes HMAC with SHA1 of #raw("binary") with the given #raw("key").
]

#function-def("fn-hmac-sha256", "hmac_sha256(binary, key)", "varbinary")[
Computes HMAC with SHA256 of #raw("binary") with the given #raw("key").
]

#function-def("fn-hmac-sha512", "hmac_sha512(binary, key)", "varbinary")[
Computes HMAC with SHA512 of #raw("binary") with the given #raw("key").
]
