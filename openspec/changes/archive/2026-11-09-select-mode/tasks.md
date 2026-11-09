# Tasks

## 1. State

- [x] 1.1 `TaskSelectionState` with `active`, `refs`, `sticky` and `anchor`; `enter`, `exit`, `toggle`,
      `selectRange` and `selectAll` on `TaskSelection`

## 2. Components

- [x] 2.1 `TaskPick` checkbox labelled Select, and `TaskCheck(inert: true)`
- [x] 2.2 `TaskRow` draws both in select mode and gains a trailing "more" button
- [x] 2.3 `TaskCard` draws both in select mode and hides its dots there; secondary click opens the menu
- [x] 2.4 The tick reads "Mark done"

## 3. Screens

- [x] 3.1 Select button in the app bar, bulk bar while select mode is on, back leaves it
- [x] 3.2 Shared tap handling: Shift range, Ctrl/Cmd pick, tap picks in select mode
- [x] 3.3 Long press picks on list rows, lane cards and board cards; menu moves to the dots
- [x] 3.4 Board and lanes draw checkboxes and pick through the same provider; no drag in select mode
- [x] 3.5 `x`, Shift+Up, Shift+Down, `e` and Escape registered as commands
- [x] 3.6 The bulk bar's count is a live region and its actions are off with nothing picked
- [x] 3.7 Strings in English, Bulgarian, German and French

## 4. Tests

- [x] 4.1 Provider tests: picking starts and ends the mode, the Select button keeps it, ranges
- [x] 4.2 Row tests: checkbox and inert tick, the dots and the long press
- [x] 4.3 Screen tests: each way in and out, range select, the inert tick, keys, board and lanes selection
