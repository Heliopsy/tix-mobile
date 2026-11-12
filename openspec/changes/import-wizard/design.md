# Design

## Where it lives

The wizard is a screen of the `transfer` feature, `ImportScreen`, routed under Manage at `transfer/import`. The
transfer screen's import section keeps its project picker and opens the wizard on that project; project settings
links to the same route through `Routes.importTasks`, so no feature imports another.

## State

`ImportWizard` (a Riverpod notifier, auto-disposed with the screen) holds an immutable `ImportDraft`: the step,
the project, the source (file name and text, or pasted lines), the column choices, the value choices, the unknown
policies, the mode, the last dry run and the committed result. Steps never re-read the file; the text stays in
memory for the screen's life, as the web keeps the upload staged.

## The mapping

`ImportDraft.mapping` writes the choices as a JSON mapping file, which tix's YAML reader takes as it is:

```json
{"version": 1, "columns": {"Summary": "title"}, "values": {"status": {"Open": "todo"}},
 "unknown": {"assignee": "skip_row"}}
```

As on the web, once the columns step has been seen every column is written down, the suggestion included, so what
the person saw is what runs. Values carry every non-empty choice, the server's suggestions included. A pasted list
sends no mapping. The mode is sent as `mode`, not in the mapping. Nothing is validated in the app; a bad mapping
comes back as the server's refusal on the step that sent it.

## Dry runs

Leaving the upload, columns and values steps each runs a dry run with `preview: 200`, so the next step reads
fresh columns and values. Changing the mode on the preview runs one again. Import sends the same request with
`dry_run: false`.

## Error report

`importErrorsCsv` writes `line,error` plus the previewed row's fields (reference, title, status, priority,
assignee, tags, due, parent, external id) when the row is in the preview, quoting as RFC 4180 and guarding cells
that start with `=`, `+`, `-` or `@` as tix's `GuardCell` does. It is saved through `Attachments.saveBytes`, as an
export is.
