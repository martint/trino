# Trino docs in Typst

The Trino documentation, migrated from MyST-Markdown/Sphinx to [Typst](https://typst.app)
and rendered with Typst's experimental
[HTML](https://typst.app/docs/reference/html/) +
[bundle](https://typst.app/docs/reference/bundle/) export.

The Typst `.typ` files under `src/` are the **source of truth**. The whole site
is built by Typst alone — no Python at build time:

```bash
# Typst 0.15.0+ on PATH (HTML export needs >= 0.15 for MathML)
typst compile --features bundle,html --format bundle docs.typ out
# -> out/<page>.html (644 pages) + out/trino.css
```

`docs.typ` is the bundle entry: it declares one `document(...)` per page, wraps
each in the page shell (nav + theme), and emits `trino.css` as a bundle asset.
Cross-references resolve natively — a `#link(label("fn-abs"))` in one page is
turned into the correct relative URL to whichever page defines `<fn-abs>` by the
bundle exporter, so there is no external link index.

## Layout

| Path | Purpose |
|------|---------|
| `lib/trino-docs.typ` | Prelude: `target()`-gated show rules + functions emitting semantic HTML for admonitions, SQL function defs (with labels), code, tables, the page shell, and the nav sidebar. |
| `src/**.typ` | The documentation source of truth (mirrors the old Sphinx tree). |
| `docs.typ` | Bundle entry point — the build target. |
| `theme/trino.css` | Hand-written theme (Typst HTML export emits no CSS). |
| `out/` | Built site (git-ignored). |

## Migration tooling (one-shot)

`myst2typ.py` + `migrate.py` converted the original MyST sources under
`../src/main/sphinx` into `src/**.typ` and generated `docs.typ`. They are **not
part of the build** — kept only to re-run the migration while the MyST sources
still exist. They need `markdown-it-py` + `mdit-py-plugins`:

```bash
python3 -m venv .venv && .venv/bin/pip install markdown-it-py mdit-py-plugins
.venv/bin/python migrate.py --all     # regenerate src/ + docs.typ
```

## Fidelity

Output is compared against the canonical Sphinx build (`docs/build`): 598 of 606
content pages render within ±15% of the canonical text, median 0.985. Handled:
`{include}`/`{literalinclude}` fragments, nested `{toctree}` page contents, MyST
substitutions (`{{breaking}}`, per-page front-matter, `|trino_version|`),
empty-text reference links (`[](/path)` → target title), `{figure}` images
(emitted as bundle assets), and case-variant admonitions.

## Known content gaps

Tracked by `migrate.py`'s warning report (do not block the build):

- Raw HTML blocks (`{raw}`) are dropped — Typst HTML export cannot pass through
  arbitrary HTML, so e.g. the decorative connector-logo grid is lost.
- ~330 unresolved `{ref}`/`{data}`/`{func}` references (genuinely missing
  targets or directive-level anchors) and the `{download_gh}`/`{download_mc}`
  roles degrade to plain text.
- Deeply nested section landing pages (e.g. `language`) render a shallower
  in-page table of contents than Sphinx.
