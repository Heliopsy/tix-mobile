# Proposal

## Why

tix records the channel and the API token behind every change. History and Watch name it now
(`history-token-name`), but the audit log rows showed the kind and the token as loose fragments, and comments showed
nothing, so a comment an agent posted with a token looked the same as one typed by hand. tix also gained emoji
reactions on comments (heliopsy/tix#318), which the app could not show or add.

## What Changes

- The audit log rows and each comment name the channel and the token or job that made the change with the same
  wording as history and Watch ("via token ci-agent"). A comment's channel comes from its `comment.add` audit entry,
  and from the `comment.added` event while the task is open. Token ids and secrets are never shown.
- Comments show their reactions as chips (emoji and count, marked when the viewer reacted). A tap toggles the
  viewer's reaction, a long press lists who reacted, and an add button opens a picker of 👍 👎 ❤️ 🎉 😄 😕 👀 🚀.
- `comment.reacted` and `comment.unreacted` refresh an open task's comments.
- A server older than reactions answers 404; the add button then goes away, and the rest of the comment is unchanged.
- tix.lock moves to the merge commit of heliopsy/tix#318, which brings `comment.react` and `comment.unreact`.

## Impact

- Capabilities: `task-detail`, `audit-log`.
- Code: `core/events`, `core/design` (reaction chip), `data/repositories`,
  `features/tasks`, `features/audit`, l10n (four strings).
