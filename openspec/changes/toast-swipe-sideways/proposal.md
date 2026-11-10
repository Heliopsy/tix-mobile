# Proposal

## Why

A toast can only be swiped down to dismiss it. On a phone the natural gesture is a sideways flick, and on a wide
window the toast floats where a downward swipe feels odd. People try left or right and nothing happens.

## What Changes

- The theme's `SnackBarThemeData.dismissDirection` is horizontal, so every snack bar, including any shown without
  `showTixToast`, can be swiped left or right.
- `showTixToast` also hides its toast on a downward fling or a drag past half its height, so down keeps working.

## Impact

`core/design/theme.dart`, `core/design/components/toast.dart`, the instances screen's export confirmation (now a
`showTixToast`) and `test/core/design/components/toast_test.dart`.
