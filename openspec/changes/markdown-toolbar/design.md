# Design

## Toolbar over the text, not a WYSIWYG view

The web keeps the textarea as the field and lets ProseMirror write Markdown back into it. A Flutter WYSIWYG package
would need its own Markdown codec and a fidelity check like the web's to avoid rewriting text it did not touch.
A toolbar that edits the Markdown text directly cannot rewrite untouched text, needs no dependency, and every web
tool has a direct Markdown form. The existing Write / Preview switch (drawn with `TixMarkdown`) is the "see it
formatted" half.

## Where the code lives

- `lib/src/core/markdown/format.dart`: pure transforms over `TextEditingValue` (`applyMarkdownFormat`,
  `continueMarkdownList`) and `MarkdownListFormatter`, a `TextInputFormatter` for list continuation. No widgets.
- `lib/src/core/design/components/markdown_toolbar.dart`: `MarkdownToolbar` (buttons plus the link prompt) and
  `MarkdownShortcuts` (the chords). Both features use them, so they sit in `core/design`, with a gallery entry
  and goldens.

## Matching the web's output

The markers are what the web's serialiser writes: `**` strong, `*` em, `~~` strike, `` ` `` code, `##` for its one
heading level, `-` bullets, `1.` numbers, `- [ ]` checklist items, `>` quotes. A link around a selection is
`[text](url)` with `(`, `)`, `"` escaped and spaces as `%20`; with nothing selected an absolute address is written
`<url>`, as the web writes a link whose text is its address. Code is inline backticks for a selection inside one
line and a fenced block otherwise, as the web's Code tool. Table inserts the web's empty two by two table.

## Toggling

A tool that finds its own markup around or at the edges of the selection removes it; otherwise it adds it. Line
tools act on every line the selection touches: if all non-blank ones already carry the prefix it comes off,
otherwise any other list, quote or heading prefix is replaced. Checklist on a list item adds or removes `[ ]`.

## Keys

Ctrl+B, Ctrl+I and Ctrl+` are bound only inside the field, so they never reach the shared key table, which binds
chords outside fields only except Ctrl+K. Ctrl+K inside a field opens the palette on both clients; it is left alone.
