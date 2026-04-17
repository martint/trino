# Release 481 - SQL/JSON typed-item model

## General

* Add support for SQL:2023 `datetime()` format templates in JSON path expressions.
  `JSON_VALUE` can now return `DATE`, `TIME`, `TIME WITH TIME ZONE`, `TIMESTAMP`,
  and `TIMESTAMP WITH TIME ZONE` results from formatted strings.
* Add support for `like_regex` in JSON path expressions.
* Add the `JSON_SERIALIZE` expression and the `JSON(...)` literal constructor
  with optional `FORMAT JSON` clause. If a user-defined SQL function named `json`
  exists, it is no longer invocable via the bare `json(x)` form — use a fully
  qualified name.
* Add the `json_scalar(x)` function that produces a JSON scalar value from an
  SQL scalar, preserving the source SQL type in the typed-item encoding.
* Add `CAST(json AS date/time/timestamp[(p)][with time zone])` and the reverse
  datetime-to-JSON casts. JSON scalars produced from datetime values preserve
  the original SQL type in the typed-item encoding.
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
  covered.

## SPI

* {{breaking}} Add `JsonBlock`, `JsonBlockBuilder`, and `JsonBlockEncoding` for
  JSON column storage. The encoding name is `JSON` and replaces the previous
  variable-width storage for JSON columns. Existing spill files and
  fault-tolerant snapshots produced by older servers are not compatible with
  the new encoding; operators must drain spill state before upgrading.
  Connectors that produce JSON blocks should use `JsonType#createBlockBuilder`
  to construct blocks.
