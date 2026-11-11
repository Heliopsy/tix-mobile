# Tasks

## 1. Spec

- [ ] 1.1 `task-detail` delta

## 2. Missing route

- [ ] 2.1 `TixException.missingRoute`, `ReactionsUnsupported` from the repository on a missing route only
- [ ] 2.2 A 404 for a comment shows the server's error and reloads the thread; a missing route says reactions are
      unsupported

## 3. Optimistic toggle

- [ ] 3.1 Draw the toggle at once in tix's order, keep the server's answer, roll back on refusal
- [ ] 3.2 One toggle at a time per comment, a repeated tap on a pending chip ignored

## 4. Picker and chip

- [ ] 4.1 Any one emoji in the picker, the server's reason on refusal
- [ ] 4.2 Long press on a comment outside its text opens the picker
- [ ] 4.3 Chip semantics say "you reacted", 48 dp hit area

## 5. Tests

- [ ] 5.1 Missing comment vs missing route, optimistic draw, rollback, ordering, any emoji, semantics
