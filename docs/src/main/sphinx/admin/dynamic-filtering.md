# Dynamic filtering

The engine does not currently collect dynamic filters from joins. Queries execute
with their ordinary join and filter semantics, and scans receive an unconstrained
connector `DynamicFilter`. Dynamic-filter query statistics report zero filters.

The connector interface and dynamic-filter configuration properties are retained,
but enabling dynamic filtering does not currently cause join-derived pruning.
