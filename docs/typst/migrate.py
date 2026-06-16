#!/usr/bin/env python3
"""migrate.py — one-shot migration of the Trino MyST docs to Typst source.

This is a migration tool, not part of the ongoing build. It converts the MyST
sources under ../src/main/sphinx into Typst source files under ./src and writes
the ./docs.typ bundle entry. After it has run, the docs are built with Typst
alone and Python is no longer needed:

    typst compile --features bundle,html --format bundle docs.typ out

Usage:
  migrate.py            emit the pilot slice
  migrate.py --all      emit every page
"""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

import myst2typ

HERE = Path(__file__).resolve().parent
SPHINX_ROOT = HERE.parent / "src" / "main" / "sphinx"
SRC = HERE / "src"

PILOT = ["index", "overview", "overview/use-cases", "overview/concepts",
         "functions/math"]


def all_docpaths() -> list[str]:
    return sorted(
        str(p.relative_to(SPHINX_ROOT).with_suffix(""))
        for p in SPHINX_ROOT.rglob("*.md")
    )


def build_index() -> myst2typ.RefIndex:
    index = myst2typ.RefIndex()
    for docpath in all_docpaths():
        src = (SPHINX_ROOT / (docpath + ".md")).read_text(encoding="utf-8")
        try:
            index.scan(docpath, src)
        except Exception as e:
            print(f"  ! index scan failed for {docpath}: {e}", file=sys.stderr)
    return index


def parse_toctree(docpath: str) -> list[str]:
    """Extract ordered toctree entries from a page (first toctree only)."""
    src = (SPHINX_ROOT / (docpath + ".md")).read_text(encoding="utf-8")
    entries: list[str] = []
    in_tree = False
    base = docpath.rsplit("/", 1)[0] if "/" in docpath else ""
    for line in src.splitlines():
        if line.startswith("```{toctree}") or line.startswith(":::{toctree}"):
            in_tree = True
            continue
        if in_tree:
            if line.strip() in ("```", ":::"):
                break
            s = line.strip()
            if not s or s.startswith(":"):
                continue
            entry = s.split("<")[-1].rstrip(">").strip() if "<" in s else s
            entries.append((base + "/" + entry).lstrip("/") if base else entry)
    return entries


def emit_sources(index: myst2typ.RefIndex, pages: list[str]) -> dict[str, list[str]]:
    warnings: dict[str, list[str]] = {}
    for docpath in pages:
        src = (SPHINX_ROOT / (docpath + ".md")).read_text(encoding="utf-8")
        body, w = myst2typ.convert(index, docpath, src, SPHINX_ROOT)
        out = SRC / (docpath + ".typ")
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text('#import "/lib/trino-docs.typ": *\n\n' + body + "\n",
                       encoding="utf-8")
        if w:
            warnings[docpath] = w
    return warnings


def emit_docs_typ(index: myst2typ.RefIndex, pages: list[str]) -> None:
    page_set = set(pages)
    # Top-level navigation entries from the root toctree (only built pages link).
    nav_entries = []
    for entry in parse_toctree("index"):
        e = index.by_doc.get(entry)
        title = e.title if e and e.title else entry
        nav_entries.append((myst2typ.doc_label(entry), title, entry,
                            entry in page_set))

    lines = ['#import "/lib/trino-docs.typ": *', ""]
    lines.append("// Navigation entries: (document label, title, docpath, built).")
    nav_lits = ",\n  ".join(
        f"({myst2typ.typ_str(lbl)}, {myst2typ.typ_str(title)}, "
        f"{myst2typ.typ_str(dp)}, {'true' if built else 'false'})"
        for lbl, title, dp, built in nav_entries
    )
    lines.append(f"#let nav-entries = (\n  {nav_lits},\n)")
    lines.append("")
    lines.append("// Build the sidebar for the page at `current` docpath,")
    lines.append("// marking the top-level section that contains it.")
    lines.append(
        "#let nav-for(current) = nav-sidebar(nav-entries.map(e => (\n"
        "  label: e.at(0), title: e.at(1), built: e.at(3),\n"
        "  current: current == e.at(2) or current.starts-with(e.at(2) + \"/\"),\n"
        ")))"
    )
    lines.append("")
    for docpath in pages:
        e = index.by_doc.get(docpath)
        title = (e.title if e and e.title else docpath)
        css = "../" * docpath.count("/") + "trino.css"
        lines.append(
            f'#document({myst2typ.typ_str(docpath + ".html")}, page-shell(\n'
            f"  title: {myst2typ.typ_str(title + ' — Trino docs')},\n"
            f"  css: {myst2typ.typ_str(css)},\n"
            f"  nav: nav-for({myst2typ.typ_str(docpath)}),\n"
            f'  include {myst2typ.typ_str("src/" + docpath + ".typ")},\n'
            f"))"
        )
    lines.append("")
    lines.append('#asset("trino.css", read("theme/trino.css", encoding: none))')
    # Image assets: copied into assets/ (within the Typst root so read() can
    # reach them) and emitted to their output path by the bundle.
    import shutil
    assets_dir = HERE / "assets"
    if assets_dir.exists():
        shutil.rmtree(assets_dir)
    for out_rel, abs_path in sorted(index.assets.items()):
        dest = assets_dir / out_rel
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy(abs_path, dest)
        lines.append(
            f'#asset({myst2typ.typ_str(out_rel)}, '
            f'read({myst2typ.typ_str("assets/" + out_rel)}, encoding: none))'
        )
    (HERE / "docs.typ").write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--all", action="store_true")
    args = ap.parse_args()

    import shutil
    if SRC.exists():
        shutil.rmtree(SRC)
    SRC.mkdir(parents=True)

    print("Indexing all docs for cross-references...")
    index = build_index()
    print(f"  indexed {len(index.by_doc)} docs, {len(index.func_to_doc)} functions, "
          f"{len(index.label_to_doc)} labels")

    myst2typ._SUBS["version"] = os.environ.get("TRINO_VERSION", "latest")
    pages = all_docpaths() if args.all else PILOT
    index.built_docs = set(pages)
    warnings = emit_sources(index, pages)
    emit_docs_typ(index, pages)
    print(f"Emitted {len(pages)} Typst sources into {SRC} and docs.typ")
    if warnings:
        total = sum(len(w) for w in warnings.values())
        print(f"\n{total} conversion warnings across {len(warnings)} pages "
              f"(unresolved refs / unsupported constructs)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
