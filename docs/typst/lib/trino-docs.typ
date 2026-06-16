// trino-docs.typ — Typst prelude for the Trino documentation.
//
// Defines the semantic constructs used by the Trino docs (admonitions, SQL
// function definitions, cross references, code blocks, tables) and renders them
// to semantic HTML. The docs are built with Typst's experimental bundle + HTML
// export: a single project (docs.typ) emits one HTML file per page, so cross
// references use native Typst labels (`link(label("..."))`) which the bundle
// exporter resolves to relative URLs across pages — no external link index.
//
// Each construct is gated on `target()` so the same source can later also
// produce PDF output; `target()` is only available inside a context, so each
// renderer wraps its body in `context`.

// --- admonitions ------------------------------------------------------------

#let admonition(kind, title, body) = context {
  if target() == "html" {
    html.elem("div", attrs: (class: "admonition " + kind))[
      #html.elem("p", attrs: (class: "admonition-title"))[#title]
      #body
    ]
  } else {
    block(stroke: (left: 2pt + gray), inset: (left: 8pt), {
      strong(title); parbreak(); body
    })
  }
}

#let note(body) = admonition("note", "Note", body)
#let warning(body) = admonition("warning", "Warning", body)
#let important(body) = admonition("important", "Important", body)
#let caution(body) = admonition("caution", "Caution", body)

// --- cross references and links ---------------------------------------------

// An external link (issue tracker, RFC, http). Internal cross references are
// emitted directly by the converter as `link(label("..."))`.
#let xref(url, text, code: false) = context {
  let lbl = if code { raw(text) } else { text }
  if target() == "html" { html.elem("a", attrs: (href: url))[#lbl] } else { link(url)[#lbl] }
}

// The {{breaking}} substitution: a marker linking to the release notes'
// breaking-changes section.
#let breaking-marker(url) = context {
  if target() == "html" {
    html.elem("a", attrs: (href: url, class: "breaking", title: "Breaking change"))[⚠️ Breaking change:]
  } else {
    link(url)[⚠️ Breaking change:]
  }
}

// A GitHub issue/PR reference: {issue}`123` -> "#123" linking to the tracker.
#let issue(num, url) = context {
  if target() == "html" {
    html.elem("a", attrs: (href: url, class: "issue"))[\##num]
  } else {
    link(url)[\##num]
  }
}

// --- SQL function definitions -----------------------------------------------
//
// Renders `{function} name(args) -> ret` as an anchored definition carrying a
// Typst label, so {func}`name` references resolve cross-page to `#id`.

// `ref: true` attaches a Typst label so {func} references resolve here; repeated
// overloads of the same name pass `ref: false` and only carry a unique HTML id.
#let function-def(id, signature, ret, body, ref: true) = {
  let render = context {
    if target() == "html" {
      html.elem("div", attrs: (class: "function", id: id))[
        #html.elem("p", attrs: (class: "function-sig"))[
          #html.elem("code", attrs: (class: "function-name"))[#signature]
          #if ret != none [ #html.elem("span", attrs: (class: "function-ret"))[→ #ret] ]
        ]
        #html.elem("div", attrs: (class: "function-body"))[#body]
      ]
    } else {
      block[#strong(raw(signature)) #body]
    }
  }
  if ref { [#render#label(id)] } else { render }
}

// --- anchors / targets ------------------------------------------------------
//
// A MyST `(label)=` target, or a per-page document target, becomes an invisible
// labeled anchor that cross references can point at.

#let anchor(id) = context {
  if target() == "html" {
    [#html.elem("span", attrs: (id: id, class: "anchor"))[]#label(id)]
  } else {
    [#metadata(id)#label(id)]
  }
}

// --- figures / images -------------------------------------------------------

#let figure-img(src, caption, alt: "") = context {
  if target() == "html" {
    html.elem("figure", attrs: (class: "figure"))[
      #html.elem("img", attrs: (src: src, alt: alt))
      #if caption != [] { html.elem("figcaption")[#caption] }
    ]
  } else {
    figure(image(src), caption: caption)
  }
}

// --- code blocks ------------------------------------------------------------

#let code-block(lang, text) = context {
  if target() == "html" {
    html.elem("pre", attrs: (class: "highlight"))[
      #html.elem("code", attrs: (class: if lang != none { "language-" + lang } else { "" }))[#text]
    ]
  } else {
    raw(text, lang: lang, block: true)
  }
}

// --- inline roles -----------------------------------------------------------

#let kbd(text) = context {
  if target() == "html" { html.elem("kbd")[#text] } else { raw(text) }
}
#let command(text) = raw(text)
#let file-path(text) = raw(text)

// --- list-table -------------------------------------------------------------

#let list-table(rows, header-rows: 1, title: none) = context {
  if target() == "html" {
    let head = rows.slice(0, header-rows)
    let body = rows.slice(header-rows)
    html.elem("table", attrs: (class: "list-table"))[
      #if title != none { html.elem("caption")[#title] }
      #if head.len() > 0 {
        html.elem("thead")[
          #for r in head { html.elem("tr")[#for c in r { html.elem("th")[#c] }] }
        ]
      }
      #html.elem("tbody")[
        #for r in body { html.elem("tr")[#for c in r { html.elem("td")[#c] }] }
      ]
    ]
  } else {
    table(columns: rows.at(0).len(), ..rows.flatten())
  }
}

// --- headings ---------------------------------------------------------------
//
// Slugify a heading to an id (matching Docutils closely enough for in-page
// links) and emit it with that id so headings are linkable anchors.

#let slugify(s) = lower(s).replace(regex("[^a-z0-9]+"), "-").trim("-")

#let plain-text(c) = {
  if type(c) == str { c }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain-text).join("") }
  else if c.has("body") { plain-text(c.body) }
  else { "" }
}

#let setup(body) = {
  show heading: it => context {
    if target() == "html" {
      html.elem("h" + str(calc.min(it.level + 1, 6)),
        attrs: (id: slugify(plain-text(it.body))))[#it.body]
    } else { it }
  }
  body
}

// --- page shell -------------------------------------------------------------
//
// Builds a full HTML document: <head> (charset/viewport/title + stylesheet) and
// <body> (nav sidebar + main content). `nav` and `body` are content; heading
// anchors are applied to `body` via `setup`. Used by docs.typ for every page.

#let page-shell(title: "", css: "trino.css", nav: [], body) = {
  html.elem("html", attrs: (lang: "en"))[
    #html.elem("head")[
      #html.elem("meta", attrs: (charset: "utf-8"))
      #html.elem("meta", attrs: (name: "viewport", content: "width=device-width, initial-scale=1"))
      #html.elem("title")[#title]
      #html.elem("link", attrs: (rel: "stylesheet", href: css))
    ]
    #html.elem("body")[
      #html.elem("div", attrs: (class: "layout"))[
        #nav
        #html.elem("main", attrs: (class: "content"))[#setup(body)]
      ]
    ]
  ]
}

// Renders a navigation sidebar from a list of (label, title, current) entries.
// Each entry links to a page via its document label, so the bundle exporter
// computes the correct relative URL for the page currently being rendered.
#let nav-sidebar(brand: "Trino documentation", entries) = {
  html.elem("nav", attrs: (class: "sidebar"))[
    #html.elem("div", attrs: (class: "brand"))[#brand]
    #html.elem("ul")[
      #for e in entries {
        let cls = if e.current { "current" } else if not e.built { "unbuilt" } else { "" }
        html.elem("li", attrs: (class: cls))[
          #if e.built { link(label(e.label))[#e.title] } else { html.elem("span")[#e.title] }
        ]
      }
    ]
  ]
}
