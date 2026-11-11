# Tasks

## 1. Spec

- [x] 1.1 `task-detail` delta

## 2. Data

- [x] 2.1 `TixException.missingRoute` tells a server without a route from a missing record
- [x] 2.2 `Comment.reactedBy` and `Comment.withReaction` over the generated `Reaction`
- [x] 2.3 The repository sends `comment.react` and `comment.unreact` and reports a server without them
- [x] 2.4 Bind `comment.react` and `comment.unreact` in the capability registry

## 3. Task screen

- [x] 3.1 `TaskComments.toggleReaction` draws at once, keeps the server's answer, undoes on failure
- [x] 3.2 Per-connection reaction support: proven by reactions on a comment, refused by an unknown route
- [x] 3.3 Reaction chips under each comment, the reader's highlighted by actor id, tap to toggle, spoken labels
- [x] 3.4 Add button and long press open the picker: eight quick emoji and a field for any one
- [x] 3.5 None on queued comments or offline drafts
- [x] 3.6 Strings in English, Bulgarian, German and French

## 4. Live updates

- [x] 4.1 `comment.reacted` and `comment.unreacted` refresh the thread

## 5. Tests

- [x] 5.1 Reading mine and toggling locally, missing routes
- [x] 5.2 Optimistic toggle, encoded path, server answer and rollback; an unknown route marks the server
- [x] 5.3 Chips, quick pick, typed emoji, long press, hidden after refusal
- [x] 5.4 A reaction event refreshes an open thread
