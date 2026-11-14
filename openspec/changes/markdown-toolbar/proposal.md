# Proposal

## Why

tix's web edits a task description in a rich text mode with a formatting toolbar: bold, italic, strikethrough,
heading, bulleted, numbered and check lists, quote, code, link and table, with Ctrl+B, Ctrl+I and Ctrl+` and lists
that carry on when Enter is pressed. The app edits the same text as a bare Markdown field, so formatting means
remembering the syntax, and on a phone keyboard that is slow.

## What Changes

- The description editor on the task screen and the description field of the new task form gain a formatting
  toolbar with the web's tools, in the web's order. Each tool wraps or unwraps the selection, or prefixes or
  unprefixes the lines it touches, in the Markdown the web's rich mode writes (`**`, `*`, `~~`, `##`, `-`,
  `1.`, `- [ ]`, `>`, backticks or a fence, `[text](url)`, a two by two table).
- Enter at the end of a list item or quoted line starts the next one (the next number, an unticked box); Enter on
  an empty one ends the list.
- Ctrl+B, Ctrl+I and Ctrl+` (Cmd on a Mac) toggle bold, italic and code in those fields, as on the web. Ctrl+K stays
  the command palette, which it is inside fields on both the web and the app, so a link comes from the toolbar.
- On a phone the toolbar sits under the field, just above the keyboard; on a wider window it sits above the field.
- The text stays Markdown. Opening and saving without an edit sends nothing new, and every tool only touches the
  lines it acts on, so the web and the app round-trip the same text.

Comments stay a plain Markdown field: the web has no rich mode there either.

## Not in this change

A WYSIWYG editor. The toolbar over the Markdown field matches every tool the web offers without a new dependency.
