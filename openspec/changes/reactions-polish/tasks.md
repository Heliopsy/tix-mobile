# Tasks

## 1. Spec

- [x] 1.1 `task-detail` delta

## 2. Missing route

- [x] 2.1 `TixException.missingRoute`, `ReactionsUnsupported` from the repository on a missing route only
- [x] 2.2 A 404 for a comment shows the server's error and reloads the thread; a missing route says reactions are
      unsupported

## 3. Optimistic toggle

- [x] 3.1 Draw the toggle at once in tix's order, keep the server's answer, roll back on refusal
- [x] 3.2 One toggle at a time per comment, a repeated tap on a pending chip ignored

## 4. Picker and chip

- [x] 4.1 Any one emoji in the picker, the server's reason on refusal
- [x] 4.2 Long press on a comment outside its text opens the picker
- [x] 4.3 Chip semantics say "you reacted", 48 dp hit area

## 5. Tests

- [x] 5.1 Missing comment vs missing route, optimistic draw, rollback, ordering, any emoji, semantics
