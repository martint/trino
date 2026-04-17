# Release notes draft: SQL/JSON typed-item model

> Draft notes for the sql-json-* stack. Move these bullets into the `481` (or
> target) release notes file under the appropriate sections.

## General

* Add support for SQL:2023 `datetime()` format templates in JSON path expressions.
  `JSON_VALUE` can now return `DATE`, `TIME`, `TIME WITH TIME ZONE`, `TIMESTAMP`
  and `TIMESTAMP WITH TIME ZONE` results from formatted strings.
* Add support for `like_regex` in JSON path expressions.
* Add the `JSON_SERIALIZE` expression, the `json_scalar` constructor, and the
  `JSON(...)` literal constructor with optional `FORMAT JSON` clause.
* Add `RETURNING JSON` support so JSON-producing functions can return a JSON
  value directly.
* {{breaking}} `JSON` values now carry a typed SQL/JSON item in addition to
  their text form. This changes equality semantics: `JSON '1' = JSON '1.0'` is
  now `true` (semantic equality), whereas previously it relied on text form.
  The legacy text-equality behavior can be restored for a query by setting the
  `legacy_json_semantics_enabled` session property (or `json.legacy-semantics-enabled`
  configuration property).
* {{breaking}} `JSON_OBJECT` now rejects duplicate keys recursively (not just at
  the top level). The check still respects the `WITH UNIQUE KEYS` /
  `WITHOUT UNIQUE KEYS` clauses.
* {{breaking}} Casts between `JSON` and `VARIANT` are now lossless:
  - `VARIANT` date, time, timestamp values cast to `JSON` as typed items
    rather than strings. Equality against the previous string form
    (for example `JSON '"2024-10-24"'`) no longer holds.
  - `VARIANT` values of `UUID` and `BINARY` type can no longer be cast to
    `JSON` and raise `INVALID_CAST_ARGUMENT`.
  - `JSON` values with duplicate object keys can no longer be cast to
    `VARIANT`.
  - The previous text-round-trip behavior can be restored for a query by
    setting the `legacy_json_semantics_enabled` session property.
* Accept the public `JSON` type wherever `FORMAT JSON` was previously required,
  in particular as an input to `JSON_VALUE`, `JSON_QUERY` and `JSON_EXISTS`.

## SPI

* Add `JsonBlock`, `JsonBlockBuilder`, and `JsonBlockEncoding` for JSON column
  storage. Connectors that produce JSON blocks should use
  `JsonType#createBlockBuilder` to construct blocks.

## JDBC driver

* Add support for the typed JSON client protocol, enabled by the
  `JSON_TYPE` client capability. When enabled, `ResultSet#getObject` on a
  `JSON` column returns an `io.trino.client.JsonValue` that exposes both the
  JSON text and (when available) a binary-encoded parsed item.

---

> TODO for the stack author:
> - Add issue numbers (the `{issue}` references above are placeholders).
> - Decide on the removal timeline for `legacy_json_semantics_enabled`.
> - Describe what JDBC clients should do when the typed protocol is enabled but
>   they do not want the typed payload (e.g. use `jsonText()`).
> - Confirm the list of functions accepting public `JSON` as `FORMAT JSON` input.
> - If `JSON_OBJECT`/`JSON_ARRAY`/`JSON_OBJECTAGG`/`JSON_ARRAYAGG` now preserve
>   typed values end-to-end (rather than round-tripping through text), mention it.
