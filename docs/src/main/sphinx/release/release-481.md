# Release 481 - SQL/JSON typed-item model

## General

* Add support for SQL:2023 `datetime()` format templates in JSON path expressions.
  `JSON_VALUE` can now return `DATE`, `TIME`, `TIME WITH TIME ZONE`, `TIMESTAMP`,
  and `TIMESTAMP WITH TIME ZONE` results from formatted strings. Trino's
  `datetime()` accepts the standard SQL/JSON template tokens with two
  Trino-specific extensions: the `RR` two-digit year template is anchored at
  1970 (matching Trino's existing `to_timestamp` behavior) instead of the
  spec's century-relative pivot, and `FF10`..`FF12` extend the spec's
  `FF1`..`FF9` so subsecond precision can match `TIMESTAMP(p)` columns up to
  `p = 12`.
* Add support for `like_regex` and `starts_with` predicates in JSON path
  expressions. Both predicates return `FALSE` (not `UNKNOWN`) when the input
  sequence is empty, in both `lax` and `strict` modes, per ISO/IEC
  9075-2:2023 §9.46.
* Add the `JSON_SERIALIZE` expression and the `JSON(...)` literal constructor
  with optional `FORMAT JSON` clause. If a user-defined SQL function named `json`
  exists, it is no longer invocable via the bare `json(x)` form — use a fully
  qualified name.
* Add the `json_scalar(x)` function that produces a JSON scalar value from an
  SQL scalar, preserving the source SQL type in the typed-item encoding.
* Add `CAST(json AS date/time/timestamp[(p)][with time zone])` and the reverse
  datetime-to-JSON casts. JSON scalars produced from datetime values preserve
  the original SQL type in the typed-item encoding. These casts are a Trino
  extension; the SQL standard does not define direct JSON↔datetime
  conversions, and the textual form (ISO-8601) is not a portable JSON
  convention.
* Add `RETURNING JSON` support so JSON-producing functions can return a JSON
  value directly. Per SQL:2023 §6.35 SR 3, combining `RETURNING JSON` with
  `OMIT QUOTES [ON SCALAR STRING]` is rejected at analysis time, since the JSON
  type cannot hold a bare unquoted scalar.
* {{breaking}} `JSON` values now carry a typed SQL/JSON item in addition to
  their text form. This changes equality semantics to follow SQL number and
  string comparison rules (SQL:2023 §8.2 GR 10) regardless of textual form:
    * Numeric equality compares on canonical decimal value, so `JSON '1'`,
      `JSON '1.0'`, and `JSON '1e0'` are all equal, and integers that exceed
      `DECIMAL(38)` precision still compare equal to same-magnitude values.
    * Non-finite numbers compare by kind: `+Infinity` equals `+Infinity`
      across `REAL` and `DOUBLE`, and similarly for `-Infinity` and `NaN`.
      Trino treats `NaN = NaN` as `true` for hashing and bucketing
      consistency; this diverges from the SQL rule where `NaN <> NaN`.
    * Numbers constructed from different underlying binary types retain their
      approximation: `CAST(REAL '1.1' AS JSON)` does not equal
      `CAST(DOUBLE '1.1' AS JSON)` because the two representations of the
      decimal literal `1.1` have different binary approximations.
    * Character-string items compare with PAD SPACE collation: trailing
      spaces are not significant, so `CHAR(5) 'ab'` and `VARCHAR 'ab'`
      compare equal regardless of storage width.
    * `TIMESTAMP WITH TIME ZONE` values compare on the underlying instant,
      so `TIMESTAMP '2024-01-01 00:00:00 UTC'` equals
      `TIMESTAMP '2024-01-01 02:00:00 +02:00'` when both are stored as JSON.
      This matches Trino's general SQL comparison rule but diverges from
      strict SQL:2023 where `WITH TIME ZONE` values may be compared by both
      instant and offset.
    * The arbitrary-precision `NUMBER` type can hold `NaN`, `+Infinity`, and
      `-Infinity` sentinel values from path-engine operations
      (`abs`, `double()`, etc.). These values participate in numeric
      equality, but cannot be serialized to JSON text since JSON does not
      represent non-finite numbers; `JSON_QUERY` and `JSON_SERIALIZE` raise
      a clear error rather than producing invalid JSON.
    * `CAST(NUMBER 'NaN' AS JSON)` (and the `+Infinity` / `-Infinity`
      counterparts) emits the JSON string `"NaN"` (etc.) for backward
      compatibility, while `CAST(DOUBLE 'NaN' AS JSON)` emits a typed
      DOUBLE non-finite item. The two are therefore not `JSON =`-equal,
      even though both ultimately mean "not a number" — preserving the
      legacy `cast(NUMBER ... AS JSON)` text contract.
* {{breaking}} `JSON_OBJECT` now rejects duplicate keys recursively (not just at
  the top level). The check still respects the `WITH UNIQUE KEYS` /
  `WITHOUT UNIQUE KEYS` clauses; there is no session-property opt-out.
* {{breaking}} The `json2016` internal type name has been removed from the
  client type catalog. A server-side alias is kept so existing plans and SQL
  continue to work, but clients and plugins should migrate to `json`.
* Accept the public `JSON` type wherever `FORMAT JSON` was previously required.
  JSON-typed values, and values produced by `JSON_QUERY`, `JSON_OBJECT`, and
  `JSON_ARRAY`, are treated as implicit `FORMAT JSON` input to `JSON_VALUE`,
  `JSON_QUERY`, `JSON_EXISTS`, `JSON_OBJECT` (as a member value) and
  `JSON_ARRAY` (as an element). `JSON_OBJECTAGG` and `JSON_ARRAYAGG` are not yet
  covered. `JSON_SERIALIZE`, the `JSON(...)` constructor, and `json_scalar(x)`
  also accept the public `JSON` type as input.
* JSON path evaluation now caps recursion at 1000 levels for both the
  `$..` descendant accessor and JSON text parsing, returning a clear error
  rather than `StackOverflowError` on pathological inputs.
* Numeric path methods (`.abs()`, `.ceiling()`, `.floor()`, `.double()`)
  now accept the arbitrary-precision `NUMBER` type, in addition to the SQL
  numeric types they already handled.

## SPI

* {{breaking}} Add `JsonBlock`, `JsonBlockBuilder`, and `JsonBlockEncoding` for
  JSON column storage. The encoding name is `JSON` and replaces the previous
  variable-width storage for JSON columns. Existing spill files and
  fault-tolerant snapshots produced by older servers are not compatible with
  the new encoding; operators must drain spill state before upgrading.
  Connectors that produce JSON blocks should use `JsonType#createBlockBuilder`
  to construct blocks.

## JDBC driver

* Add support for the typed JSON client protocol, enabled by the
  `JSON_PARSED_ITEM_ENCODING` client capability. `ResultSet#getObject` on a
  `JSON` column continues to return the JSON text as a `String`. Callers that
  want the typed representation can ask for it explicitly with
  `ResultSet#getObject(column, io.trino.client.JsonColumnValue.class)`; the
  returned `JsonColumnValue` exposes both the JSON text and the binary-encoded
  parsed item. The parsed-item encoding is an implementation detail of the
  server-client protocol and is not stable across Trino versions.

## CLI

* Negotiate the `JSON_PARSED_ITEM_ENCODING` client capability automatically.
  CLI output of `JSON` columns continues to use the canonical JSON text form;
  the typed parsed-item encoding is not exposed at the CLI surface.
