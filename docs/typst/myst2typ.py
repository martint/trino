"""myst2typ — convert Trino's MyST-Markdown docs to Typst markup.

The converter runs in two passes (see build.py):

  1. An index pass scans every source file for the cross-reference anchors that
     {doc}, {ref} and {func} roles point at (document paths, explicit `(label)=`
     targets, SQL function definitions, headings).
  2. A render pass walks each file's MyST token tree and emits Typst markup that
     calls into lib/trino-docs.typ. Cross-reference roles are resolved here, in
     Python, into relative `.html` URLs using the index from pass 1 — Typst
     compiles each page independently and cannot resolve links across pages.

Only the constructs used by the pilot slice are handled fully; unknown
directives/roles degrade to a visible TODO marker rather than failing, so gaps
are easy to spot.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path

from markdown_it import MarkdownIt
from markdown_it.tree import SyntaxTreeNode
from mdit_py_plugins.colon_fence import colon_fence_plugin
from mdit_py_plugins.deflist import deflist_plugin
from mdit_py_plugins.front_matter import front_matter_plugin
from mdit_py_plugins.myst_role import myst_role_plugin

ISSUE_TRINO = "https://github.com/trinodb/trino/issues/{}"
ISSUE_PRESTO = "https://github.com/prestodb/presto/issues/{}"

# MyST `(label)=` target lines, handled by preprocessing into a fenced marker.
TARGET_RE = re.compile(r"^\(([\w.-]+)\)=\s*$", re.MULTILINE)

DIRECTIVE_INFO_RE = re.compile(r"^\{([\w-]+)\}\s*(.*)$", re.DOTALL)

# MyST substitutions from conf.py. `breaking` maps to HTML, so it is routed
# through a sentinel and rendered by the prelude; the rest are plain text.
BREAKING_SENTINEL = "BREAKING"
_SUBS = {"version": "latest"}
_PAGE_SUBS: dict[str, str] = {}  # per-page front-matter substitutions


def make_parser() -> MarkdownIt:
    md = (
        MarkdownIt("commonmark")
        .enable(["table"])
        .use(front_matter_plugin)
        .use(colon_fence_plugin)
        .use(deflist_plugin)
        .use(myst_role_plugin)
    )
    return md


def slugify(text: str) -> str:
    """Heading -> id, matching the prelude's slugify and Docutils closely."""
    return re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")


# Cross-reference labels live in three namespaces so a function, an explicit
# target, and a document path can't collide on the same Typst label.
def func_label(name: str) -> str:
    return "fn-" + slugify(name)


def doc_label(docpath: str) -> str:
    return "doc-" + slugify(docpath)


def ref_label(label: str) -> str:
    return "ref-" + slugify(label)


# --------------------------------------------------------------------------- #
# Cross-reference index
# --------------------------------------------------------------------------- #


@dataclass
class DocEntry:
    """A source document and the anchors it defines."""

    docpath: str  # e.g. "functions/math" (no extension), relative to sphinx root
    out_url: str  # e.g. "functions/math.html"
    title: str = ""
    labels: set[str] = field(default_factory=set)  # explicit (label)= targets
    functions: set[str] = field(default_factory=set)  # {function} names
    headings: set[str] = field(default_factory=set)  # heading slugs


class RefIndex:
    """Global cross-reference index across all converted documents."""

    def __init__(self) -> None:
        self.by_doc: dict[str, DocEntry] = {}
        self.label_to_doc: dict[str, str] = {}  # label -> docpath
        self.func_to_doc: dict[str, str] = {}  # function name -> docpath
        self.assets: dict[str, Path] = {}  # output path -> source image file
        self.used_ids: set[str] = set()  # HTML/label ids claimed during render
        # Docs included in the current build; None means "all known docs".
        # Cross references into docs outside this set degrade to plain text so
        # the bundle never links to a label that was not emitted.
        self.built_docs: set[str] | None = None

    def _built(self, docpath: str | None) -> bool:
        return docpath is not None and (self.built_docs is None
                                        or docpath in self.built_docs)

    def unique_id(self, base: str) -> tuple[str, bool]:
        """Return a unique id for `base`; the bool is True if it is the first
        (canonical, referenceable) use of `base`."""
        if base not in self.used_ids:
            self.used_ids.add(base)
            return base, True
        i = 2
        while f"{base}-{i}" in self.used_ids:
            i += 1
        uid = f"{base}-{i}"
        self.used_ids.add(uid)
        return uid, False

    def scan(self, docpath: str, source: str) -> None:
        entry = DocEntry(docpath=docpath, out_url=docpath + ".html")
        self.by_doc[docpath] = entry
        md = make_parser()
        tree = SyntaxTreeNode(md.parse(preprocess(source)))
        first_heading = True
        for node in tree.walk():
            if node.type == "heading":
                text = node_plain_text(node)
                if first_heading:
                    entry.title = text
                    first_heading = False
                entry.headings.add(slugify(text))
            elif node.type in ("fence", "colon_fence"):
                m = DIRECTIVE_INFO_RE.match(node.info.strip())
                if not m:
                    continue
                name, arg = m.group(1), m.group(2).strip()
                if name in ("function", "data"):
                    fname = parse_function_signature(arg)[0]
                    if fname:
                        entry.functions.add(fname)
                        self.func_to_doc.setdefault(fname, docpath)
                elif name == "_target":
                    label = node.content.strip()
                    entry.labels.add(label)
                    self.label_to_doc.setdefault(label, docpath)

    def resolve_doc(self, from_doc: str, target: str) -> str | None:
        """Normalize a {doc}`path` target; return the docpath if it is built."""
        target = re.sub(r"\.md$", "", target.lstrip("/"))
        norm = normalize_docpath(from_doc, target)
        return norm if (norm in self.by_doc and self._built(norm)) else None

    def ref_exists(self, label: str) -> bool:
        return self._built(self.label_to_doc.get(label))

    def func_exists(self, name: str) -> bool:
        return self._built(self.func_to_doc.get(name))


def normalize_docpath(from_doc: str, target: str) -> str:
    """Resolve a possibly-relative doc reference against the referring doc."""
    if target.startswith("../") or target.startswith("./"):
        base = from_doc.split("/")[:-1]
        parts = base + target.split("/")
        out: list[str] = []
        for p in parts:
            if p in ("", "."):
                continue
            if p == "..":
                if out:
                    out.pop()
            else:
                out.append(p)
        return "/".join(out)
    return target


def relative_url(from_doc: str, to_url: str) -> str:
    """Relative URL from one doc's output page to another output path."""
    from_dir = from_doc.split("/")[:-1]
    to_parts = to_url.split("/")
    # strip common prefix
    i = 0
    while i < len(from_dir) and i < len(to_parts) - 1 and from_dir[i] == to_parts[i]:
        i += 1
    ups = [".."] * (len(from_dir) - i)
    return "/".join(ups + to_parts[i:]) or to_url


# --------------------------------------------------------------------------- #
# Helpers
# --------------------------------------------------------------------------- #


def parse_front_matter_subs(source: str) -> dict[str, str]:
    """Extract `myst.substitutions` from a page's YAML front matter."""
    subs: dict[str, str] = {}
    if not source.startswith("---"):
        return subs
    end = source.find("\n---", 3)
    if end < 0:
        return subs
    in_sub = False
    sub_indent = 0
    for line in source[3:end].splitlines():
        if re.match(r"^\s*substitutions:\s*$", line):
            in_sub = True
            sub_indent = len(line) - len(line.lstrip())
            continue
        if in_sub:
            if not line.strip():
                continue
            if len(line) - len(line.lstrip()) <= sub_indent:
                break
            m = re.match(r"^\s*([\w-]+):\s*(.*)$", line)
            if m:
                v = m.group(2).strip()
                if len(v) >= 2 and v[0] in "\"'" and v[-1] == v[0]:
                    v = v[1:-1]
                subs[m.group(1)] = v
    return subs


def preprocess(source: str) -> str:
    """Apply MyST substitutions and turn `(label)=` target lines into a fenced
    `{_target}` directive."""
    source = source.replace("|trino_version|", _SUBS["version"])
    source = source.replace("{{breaking}}", BREAKING_SENTINEL)
    for k, v in _PAGE_SUBS.items():
        source = source.replace("{{" + k + "}}", v)
    return TARGET_RE.sub(lambda m: f"```{{_target}}\n{m.group(1)}\n```", source)


def node_plain_text(node: SyntaxTreeNode) -> str:
    if node.type == "text":
        return node.content
    if node.type in ("code_inline", "fence", "code_block"):
        return node.content
    return "".join(node_plain_text(c) for c in node.children)


def parse_function_signature(arg: str) -> tuple[str, str, str | None]:
    """Parse `name(args) -> ret` into (name, signature, return-type)."""
    arg = arg.strip()
    ret = None
    if "->" in arg:
        sig, ret = arg.split("->", 1)
        sig, ret = sig.strip(), ret.strip()
    else:
        sig = arg
    m = re.match(r"([\w.$]+)", sig)
    name = m.group(1) if m else ""
    return name, sig, ret


# Typst markup special characters to escape in plain-text runs. Parens and
# slash are included because a text run beginning with `(`, `/`, `[` ... right
# after an emitted #func[...] is otherwise parsed as a call/term-list marker.
_ESCAPE_RE = re.compile(r"([\\#$*_`<>@~\[\]()/])")


def esc(text: str) -> str:
    return _ESCAPE_RE.sub(r"\\\1", text)


def typ_str(text: str) -> str:
    """Quote a Python string as a Typst string literal."""
    return '"' + text.replace("\\", "\\\\").replace('"', '\\"') + '"'


# --------------------------------------------------------------------------- #
# Renderer
# --------------------------------------------------------------------------- #


class Renderer:
    def __init__(self, index: RefIndex, docpath: str,
                 source_root: Path | None = None, cur_dir: str = "") -> None:
        self.index = index
        self.docpath = docpath
        self.source_root = source_root
        # Directory (relative to source_root) of the file currently being
        # parsed, so {include} paths resolve relative to the right file.
        self.cur_dir = cur_dir
        self.warnings: list[str] = []

    # -- inline ----------------------------------------------------------- #

    def inline(self, node: SyntaxTreeNode) -> str:
        out = []
        for c in node.children:
            out.append(self.inline_node(c))
        return "".join(out)

    def inline_node(self, n: SyntaxTreeNode) -> str:
        t = n.type
        if t == "text":
            if BREAKING_SENTINEL in n.content:
                url = relative_url(self.docpath, "release.html") + "#breaking-changes"
                marker = f"#breaking-marker({typ_str(url)})"
                return marker.join(esc(p) for p in n.content.split(BREAKING_SENTINEL))
            return esc(n.content)
        if t == "softbreak":
            return " "
        if t == "hardbreak":
            return " \\\n"
        if t == "code_inline":
            return "#raw(" + typ_str(n.content) + ")"
        if t == "strong":
            return "#strong[" + self.inline(n) + "]"
        if t == "em":
            return "#emph[" + self.inline(n) + "]"
        if t == "link":
            return self.link_expr(n.attrs.get("href", ""), self.inline(n))
        if t == "image":
            src = n.attrs.get("src", "")
            alt = node_plain_text(n)
            return "#image(" + typ_str(src) + ', alt: ' + typ_str(alt) + ")"
        if t == "myst_role":
            return self.role(n.meta.get("name", ""), n.content)
        if t == "html_inline":
            return ""  # raw inline HTML dropped in pilot
        # Fallback: render children if any, else escaped content.
        if n.children:
            return self.inline(n)
        return esc(n.content)

    def doc_title_of(self, norm: str) -> str:
        e = self.index.by_doc.get(norm)
        return e.title if e and e.title else norm

    def link_expr(self, href: str, inner: str) -> str:
        """Render a Markdown link, resolving internal doc links natively. An
        empty link text (MyST `[](/path)`) is filled with the target's title."""
        if href.startswith(("http://", "https://", "mailto:", "#")):
            return f"#link({typ_str(href)})[{inner}]"
        base, sep, frag = href.partition("#")
        # `[text](label-name)` — a MyST reference to an explicit target label.
        if not base.endswith(".md") and "/" not in base and not frag \
                and self.index.ref_exists(base):
            if not inner.strip():
                inner = esc(self.doc_title_of(self.index.label_to_doc[base]))
            return f"#link(label({typ_str(ref_label(base))}))[{inner}]"
        base = re.sub(r"\.md$", "", base)
        if base.startswith("/"):
            norm = base.lstrip("/")  # root-relative doc reference, e.g. [t](/sql)
        else:
            norm = normalize_docpath(self.docpath, base) if base else self.docpath
        if self.index._built(norm):
            if not inner.strip():
                inner = esc(self.doc_title_of(norm))
            if not frag:
                # Fragment-less internal link -> native document label.
                return f"#link(label({typ_str(doc_label(norm))}))[{inner}]"
            # Heading fragment: bake a relative URL (no Typst label for headings).
            url = relative_url(self.docpath, norm + ".html") + "#" + frag
            return f"#link({typ_str(url)})[{inner}]"
        self.warnings.append(f"unresolved link {href}")
        return inner or esc(href)

    def role(self, name: str, content: str) -> str:
        if name == "issue":
            if content and content[0] == "x":
                num, url = content[1:], ISSUE_PRESTO.format(content[1:])
            else:
                num, url = content, ISSUE_TRINO.format(content)
            return f"#issue({typ_str(num)}, {typ_str(url)})"
        if name in ("func", "data"):
            target = strip_xref_target(content)
            disp = xref_display(content)
            # MyST `~prefix` shortens the display to the trailing component;
            # function targets may carry empty call parens, e.g. `random()`.
            if target.startswith("~"):
                target = target[1:]
                disp = disp.lstrip("~").split(".")[-1]
            target = re.sub(r"\(\s*\)$", "", target).strip()
            if not self.index.func_exists(target):
                self.warnings.append(f"unresolved {{{name}}}`{content}`")
                return "#raw(" + typ_str(disp) + ")"
            return (f"#link(label({typ_str(func_label(target))}), "
                    f"raw({typ_str(disp)}))")
        if name == "doc":
            target = strip_xref_target(content)
            disp = xref_display(content)
            norm = self.index.resolve_doc(self.docpath, target)
            if norm is None:
                self.warnings.append(f"unresolved {{doc}}`{content}`")
                return esc(disp)
            title = disp if has_explicit_text(content) else self.doc_title(target, disp)
            return f"#link(label({typ_str(doc_label(norm))}))[{esc(title)}]"
        if name == "ref":
            target = strip_xref_target(content)
            disp = xref_display(content)
            if not self.index.ref_exists(target):
                self.warnings.append(f"unresolved {{ref}}`{content}`")
                return esc(disp)
            return f"#link(label({typ_str(ref_label(target))}))[{esc(disp)}]"
        if name in ("command", "file", "prop"):
            return "#raw(" + typ_str(content) + ")"
        if name == "kbd":
            return f"#kbd({typ_str(content)})"
        if name in ("sup",):
            return "#super[" + esc(content) + "]"
        if name == "abbr":
            return esc(re.sub(r"\s*\(.*\)$", "", content))
        if name == "rfc":
            url = "https://www.rfc-editor.org/rfc/rfc" + content
            return f"#link({typ_str(url)})[RFC {esc(content)}]"
        self.warnings.append(f"unknown role {{{name}}}")
        return "#raw(" + typ_str(content) + ")"

    def doc_title(self, target: str, fallback: str) -> str:
        norm = normalize_docpath(self.docpath, re.sub(r"\.md$", "", target.lstrip("/")))
        entry = self.index.by_doc.get(norm)
        return entry.title if entry and entry.title else fallback

    # -- block ------------------------------------------------------------ #

    def render(self, tree: SyntaxTreeNode) -> str:
        return self.blocks(tree.children)

    def blocks(self, nodes: list[SyntaxTreeNode]) -> str:
        return "\n\n".join(filter(None, (self.block(n) for n in nodes)))

    def block(self, n: SyntaxTreeNode) -> str:
        t = n.type
        if t == "heading":
            level = int(n.tag[1])
            return "=" * level + " " + self.inline(n)
        if t == "paragraph":
            return self.inline(n)
        if t in ("fence", "colon_fence", "code_block"):
            return self.fence(n)
        if t == "bullet_list":
            return self.list(n, ordered=False)
        if t == "ordered_list":
            return self.list(n, ordered=True)
        if t == "table":
            return self.table(n)
        if t == "blockquote":
            return "#quote(block: true)[\n" + self.blocks(n.children) + "\n]"
        if t == "front_matter":
            return ""
        if t == "hr":
            return "#line(length: 100%)"
        if t in ("dl",):
            return self.deflist(n)
        if n.children:
            return self.blocks(n.children)
        return ""

    def list(self, n: SyntaxTreeNode, ordered: bool) -> str:
        marker = "+" if ordered else "-"
        items = []
        for li in n.children:
            inner = self.blocks(li.children)
            inner = inner.replace("\n", "\n  ")
            items.append(f"{marker} {inner}")
        return "\n".join(items)

    def deflist(self, n: SyntaxTreeNode) -> str:
        out = []
        for child in n.children:
            if child.type == "dt":
                out.append("/ " + self.inline(child) + ": ")
            elif child.type == "dd":
                out[-1] = out[-1] + self.blocks(child.children).replace("\n", " ")
        return "\n".join(out)

    def fence(self, n: SyntaxTreeNode) -> str:
        info = n.info.strip()
        m = DIRECTIVE_INFO_RE.match(info)
        if m:
            return self.directive(m.group(1), m.group(2).strip(), n.content)
        lang = info.split()[0] if info else None
        return f"#code-block({typ_str(lang) if lang else 'none'}, {typ_str(n.content.rstrip())})"

    # -- directives ------------------------------------------------------- #

    def directive(self, name: str, arg: str, content: str) -> str:
        lname = name.lower()
        if lname in ("note", "warning", "important", "caution", "tip", "admonition"):
            fn = {"tip": "note", "admonition": "note"}.get(lname, lname)
            return f"#{fn}[\n" + self.subdoc(strip_options(content)) + "\n]"
        if name == "function":
            fname, sig, ret = parse_function_signature(arg)
            body = self.subdoc(strip_options(content))
            ret_arg = typ_str(ret) if ret else "none"
            fid, canonical = self.index.unique_id(func_label(fname))
            ref_arg = "" if canonical else ", ref: false"
            return (
                f"#function-def({typ_str(fid)}, {typ_str(sig)}, {ret_arg}{ref_arg})[\n"
                + body
                + "\n]"
            )
        if name == "_target":
            return f"#anchor({typ_str(ref_label(content.strip()))})"
        if name == "list-table":
            return self.list_table(arg, content)
        if name == "toctree":
            return self.toctree(content)
        if name in ("include", "literalinclude"):
            return self.include(name, arg, content)
        if name == "figure":
            return self.figure(arg, content)
        if name == "raw":
            return ""  # raw HTML/LaTeX passthrough unsupported by Typst HTML export
        if name in ("data",):
            # `{data}` defines a documented constant; render like a function.
            fname, sig, ret = parse_function_signature(arg)
            fid, canonical = self.index.unique_id(func_label(fname))
            ref_arg = "" if canonical else ", ref: false"
            return (
                f"#function-def({typ_str(fid)}, {typ_str(sig)}, none{ref_arg})[\n"
                + self.subdoc(strip_options(content))
                + "\n]"
            )
        self.warnings.append(f"unknown directive {{{name}}}")
        return (
            "#block(fill: yellow)[TODO unsupported directive: "
            + esc("{" + name + "} " + arg)
            + "]"
        )

    def figure(self, arg: str, content: str) -> str:
        """Render a {figure}, registering its image as a bundle asset."""
        if self.source_root is None:
            return ""
        rel = arg.strip()
        if rel.startswith("/"):
            abs_path = (self.source_root / rel.lstrip("/")).resolve()
        else:
            abs_path = (self.source_root / self.cur_dir / rel).resolve()
        if not abs_path.is_file():
            self.warnings.append(f"{{figure}} {arg} (image not found)")
            return ""
        out_rel = str(abs_path.relative_to(self.source_root.resolve()))
        self.index.assets[out_rel] = abs_path
        opts, body = split_directive_options(content)
        alt = opts.get("alt", "")
        src = relative_url(self.docpath, out_rel)
        caption = self.subdoc(body) if body.strip() else ""
        return (f"#figure-img({typ_str(src)}, alt: {typ_str(alt)})[\n"
                + caption + "\n]")

    def include(self, name: str, arg: str, content: str) -> str:
        """Inline an {include} fragment, or a {literalinclude} as a code block."""
        if self.source_root is None:
            self.warnings.append(f"{{{name}}} {arg} (no source root)")
            return ""
        # A leading "/" means relative to the source root (Sphinx convention),
        # otherwise relative to the including file's directory.
        rel = arg.strip()
        if rel.startswith("/"):
            target = (self.source_root / rel.lstrip("/")).resolve()
        else:
            target = (self.source_root / self.cur_dir / rel).resolve()
        if not target.is_file():
            self.warnings.append(f"{{{name}}} {arg} (file not found)")
            return ""
        text = target.read_text(encoding="utf-8")
        if name == "literalinclude":
            opts, _ = split_directive_options(content)
            lang = opts.get("language")
            return f"#code-block({typ_str(lang) if lang else 'none'}, {typ_str(text.rstrip())})"
        # MyST include: parse the fragment relative to its own directory so any
        # nested {include}s resolve correctly.
        rel_dir = str(target.parent.relative_to(self.source_root))
        rel_dir = "" if rel_dir == "." else rel_dir
        return self.subdoc(text, cur_dir=rel_dir)

    def toctree(self, content: str, base: str | None = None, depth: int = 0) -> str:
        """Render a {toctree} as a nested in-page list of links to its entries,
        recursing into each entry's own toctree (matching Sphinx's body TOC)."""
        _opts, body = split_directive_options(content)
        if base is None:
            base = self.cur_dir
        items = []
        for line in body.splitlines():
            s = line.strip()
            if not s or s.startswith(":"):
                continue
            entry = s.split("<")[-1].rstrip(">").strip() if "<" in s else s
            entry = re.sub(r"\.md$", "", entry)
            norm = (base + "/" + entry).lstrip("/") if base else entry
            e = self.index.by_doc.get(norm)
            title = e.title if e and e.title else entry
            indent = "  " * depth
            if self.index._built(norm):
                items.append(f"{indent}- #link(label({typ_str(doc_label(norm))}))[{esc(title)}]")
            else:
                items.append(f"{indent}- {esc(title)}")
            if depth < 2:
                nested = self.child_toctrees(norm, depth + 1)
                if nested:
                    items.append(nested)
        return "\n".join(items)

    def child_toctrees(self, docpath: str, depth: int) -> str:
        """Render the toctrees defined in a child document's source, if any."""
        if self.source_root is None:
            return ""
        f = self.source_root / (docpath + ".md")
        if not f.is_file():
            return ""
        child_base = docpath.rsplit("/", 1)[0] if "/" in docpath else ""
        out = []
        for block in extract_directive_blocks(f.read_text(encoding="utf-8"), "toctree"):
            rendered = self.toctree(block, base=child_base, depth=depth)
            if rendered:
                out.append(rendered)
        return "\n".join(out)

    def subdoc(self, content: str, cur_dir: str | None = None) -> str:
        """Render directive body content (which is itself MyST) to Typst."""
        md = make_parser()
        tree = SyntaxTreeNode(md.parse(preprocess(content)))
        sub = Renderer(self.index, self.docpath, self.source_root,
                       self.cur_dir if cur_dir is None else cur_dir)
        out = sub.render(tree)
        self.warnings.extend(sub.warnings)
        return out

    def list_table(self, arg: str, content: str) -> str:
        """Parse a {list-table} (nested bullet lists of rows/cells)."""
        opts, body = split_directive_options(content)
        header_rows = int(opts.get("header-rows", "0") or "0")
        title = arg.strip()
        md = make_parser()
        tree = SyntaxTreeNode(md.parse(body))
        rows = []
        for top in tree.children:
            if top.type != "bullet_list":
                continue
            for row_item in top.children:  # list_item per row
                cells = []
                for sub in row_item.children:
                    if sub.type == "bullet_list":
                        for cell_item in sub.children:
                            cells.append(self.cell(cell_item))
                rows.append(cells)
        rows_typ = ",\n  ".join(
            "(" + ", ".join(c for c in row) + ",)" for row in rows
        )
        title_arg = f", title: {typ_str(title)}" if title else ""
        return (
            f"#list-table((\n  {rows_typ}\n), header-rows: {header_rows}{title_arg})"
        )

    def cell(self, cell_item: SyntaxTreeNode) -> str:
        inner = self.blocks(cell_item.children).strip()
        return "[" + inner + "]"

    def table(self, n: SyntaxTreeNode) -> str:
        """A GFM pipe table -> list-table with one header row."""
        rows = []
        for section in n.children:  # thead / tbody
            for tr in section.children:
                cells = ["[" + self.inline(td) + "]" for td in tr.children]
                rows.append(cells)
        rows_typ = ",\n  ".join("(" + ", ".join(r) + ",)" for r in rows)
        return f"#list-table((\n  {rows_typ}\n), header-rows: 1)"


# --- xref helpers ----------------------------------------------------------- #

_EXPLICIT_RE = re.compile(r"^(.*?)<([^>]+)>$", re.DOTALL)


def has_explicit_text(content: str) -> bool:
    return bool(_EXPLICIT_RE.match(content.strip()))


def strip_xref_target(content: str) -> str:
    m = _EXPLICIT_RE.match(content.strip())
    return (m.group(2) if m else content).strip()


def xref_display(content: str) -> str:
    m = _EXPLICIT_RE.match(content.strip())
    return (m.group(1) if m and m.group(1).strip() else strip_xref_target(content)).strip()


def extract_directive_blocks(source: str, name: str) -> list[str]:
    """Return the raw body of every ```{name} / :::{name} fenced block."""
    blocks, lines, i = [], source.splitlines(), 0
    while i < len(lines):
        m = re.match(r"^(`{3,}|:{3,})\{" + name + r"\}", lines[i])
        if not m:
            i += 1
            continue
        fence = m.group(1)[0]
        i += 1
        body = []
        while i < len(lines) and not re.match(r"^" + fence + "{3,}\\s*$", lines[i]):
            body.append(lines[i])
            i += 1
        blocks.append("\n".join(body))
        i += 1
    return blocks


def strip_options(content: str) -> str:
    """Drop the leading `:option:` lines of a directive body."""
    return split_directive_options(content)[1]


def split_directive_options(content: str) -> tuple[dict[str, str], str]:
    """Split leading `:key: value` option lines from a directive body."""
    opts: dict[str, str] = {}
    lines = content.splitlines()
    i = 0
    while i < len(lines):
        m = re.match(r"^\s*:([\w-]+):\s*(.*)$", lines[i])
        if not m:
            break
        opts[m.group(1)] = m.group(2).strip()
        i += 1
    return opts, "\n".join(lines[i:])


# --------------------------------------------------------------------------- #
# Public API
# --------------------------------------------------------------------------- #


def convert(index: RefIndex, docpath: str, source: str,
            source_root: Path | None = None) -> tuple[str, list[str]]:
    global _PAGE_SUBS
    _PAGE_SUBS = parse_front_matter_subs(source)
    md = make_parser()
    tree = SyntaxTreeNode(md.parse(preprocess(source)))
    cur_dir = docpath.rsplit("/", 1)[0] if "/" in docpath else ""
    r = Renderer(index, docpath, source_root, cur_dir)
    # A per-page anchor so {doc} references can target this page by path.
    page_anchor = f"#anchor({typ_str(doc_label(docpath))})\n"
    body = page_anchor + r.render(tree)
    return body, r.warnings
