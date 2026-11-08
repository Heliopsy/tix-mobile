# Design

## OLED black

`TixTokens.oled` copies the dark scheme and changes only what lights pixels: the page goes to `#000000`, the
surface to `#0a0b0d`, the soft tints get darker and the scrim dims to black. `line` is a little brighter because it
now does the work a fill did. Text, status, priority and project colours are dark's, so a status means the same in
both dark schemes and the non-themeable rule holds. A tenant accent applies as in dark, its tint mixed 40% towards
black. Every text token is brighter against black than against dark's page, so nothing needed moving; the contrast
table in `docs/design.md` has the numbers.

## Theme choice

Four chips (System, Light, Dark, OLED black) plus a switch shown under System. A fourth chip alone cannot say
"follow the system, but black when it is dark", and a separate black switch for every choice would be on for
Light, where it means nothing. `ThemeChoice` maps to Material's `ThemeMode`; `darkIsBlackProvider` decides which
tokens the dark theme is built from. Both are per device in preferences.

SegmentedButton with four or five segments scrolled sideways at phone width, hiding options. `TixChoices` wraps
instead; it is a design-system component with a gallery entry and goldens.

## Translations

The ARB files carry values only beside the English template. `test/core/l10n/arb_test.dart` parses each message's
ICU arguments and compares names, select cases and the explicit plural cases with English; gen-l10n's
untranslated-messages report misses placeholder and case mismatches. `resolveLocale` picks by language and falls
back to English, because the generated list starts with Bulgarian, which Flutter's default would have chosen.

## About

The screen reads three providers: `appInfoProvider` (package_info_plus and the OS version), `engineVersionProvider`
(null when the build has no engine) and `serverVersionProvider` (`GET /healthz` on the active context).
`Diagnostics` is built from those strings and the remote server's address only, so it cannot carry a credential;
the address is left out of copied text unless the person turns it on. The bug link fills the issue form's
`platform`, `os-version`, `app-version`, `server-version` and `logs` fields by their ids.
