# Tasks

## 1. Spec

- [x] 1.1 `task-views` delta: quick actions, in-place status and priority, keys, the tick and the settle

## 2. Rows

- [x] 2.1 `TaskCheck`: fill with a bounce and draw the check; reversed on untick; instant with reduced motion
- [x] 2.2 `TaskRow`: strike-through sweep, muted title and a green wash; only on a change of done
- [x] 2.3 `TixMotion.settle` and `TixHaptics.light`
- [x] 2.4 Widget tests: the animation completes, reverses, does not play for a row drawn done, and respects reduced motion

## 3. Quick edits

- [x] 3.1 `TaskListing.sendPatch` and `sendTag`
- [x] 3.2 `TaskQuickActions.setPriority`, `setDue`, `addTag`; menu items for move, assign, priority, due date and tag
- [x] 3.3 Status and priority on the list row open their pickers; modifier clicks and select mode pick
- [x] 3.4 `m`, `p`, `a`, `u`, `t` on the focused row, off while a task is open beside the list
- [x] 3.5 Widget tests: chip and menu open a picker and the change goes through the listing; select mode only picks

## 4. List

- [x] 4.1 Hold a ticked row in place for the settle, then move it or collapse it when the listing drops it
- [x] 4.2 Widget tests with and without reduced motion

## 5. Strings

- [x] 5.1 English, German, French and Bulgarian; `flutter gen-l10n`
