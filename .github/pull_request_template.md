## What changed

## Why

## Spec

- [ ] Behaviour change is reflected in `openspec/` (or this PR changes no behaviour)
- [ ] `just spec` passes
- [ ] Relevant tasks ticked in `tasks.md`

## Checks

- [ ] `just check` passes locally
- [ ] New behaviour has tests in the same change
- [ ] Generated code is up to date (`just gen-check`)
- [ ] PR title is a conventional commit (release-please reads it)

## Architecture rules

- [ ] Widgets read providers only; no repository or API client calls from `presentation/`
- [ ] No feature imports another feature
- [ ] HTTP only in the API client, with no business rules there
- [ ] Listings use keyset cursors, never offsets
- [ ] Tokens stay in secure storage and out of logs
- [ ] New strings are in both `app_en.arb` and `app_bg.arb`

## Platforms

Where this was run, and at which widths if the layout changed. Screenshots for visible changes.

- [ ] Android
- [ ] iOS
- [ ] Linux
- [ ] macOS
- [ ] Windows

## Notes for reviewers
