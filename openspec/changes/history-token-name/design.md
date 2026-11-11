# Design

- **Shared, not copied.** Watch and task History are different features and may not import each other, so the
  label moves from `features/watch` to `core/l10n/via_label.dart`, next to the strings it uses.
- **The web's words.** The app matches tix's web interface (`internal/web/via.go`): an `api` channel with a token
  is "via token NAME", any other channel with a token is "via CHANNEL (token NAME)", a system channel names its
  job. Saying "token" removes the ambiguity with a job name.
- **Only the name.** The label reads `via.token_name`, which tix stores as the name the token had when the change
  was made, so a renamed or deleted token still reads as it did then. The app never sees a secret: the server
  never sends one.
- **Older servers.** Every `Via` field defaults to empty, so an entry or event without `via` (or without a token
  name) falls back to the surface, or to the bare channel.
