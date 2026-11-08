# Proposal

## Why

The dark theme lights every pixel of an OLED screen in tix's slate; a pure black page saves battery and reads
better at night. The app speaks English and Bulgarian only, and German and French are the next most asked for. The
About entry opened a stock dialog with no version, no links and no way to report a bug.

## What Changes

- An OLED black scheme beside light and dark: a `#000000` page, near-black surfaces told apart by hairlines, the
  dark text, status and priority colours unchanged, the tenant accent as in dark.
- Settings offers System, Light, Dark and OLED black, and under System a "Pure black when dark" switch. Theme and
  language pick from wrapping chips, so no option hides off screen at 200% text or in a long language.
- French and German translations of every string, a test that fails on a missing key or a placeholder, plural or
  select mismatch, and English as the fallback for any language the app does not speak.
- The 200% text tests run in English, German and French.
- An About screen: the app, engine and server versions, what tix-mobile is, links to the site, source, roadmap,
  changelog, tix and the security policy, a prefilled bug report, diagnostics to copy, and the licences.

## Impact

- Capabilities: `app-settings` and `design-system` change; `about` is new.
- New dependency: `package_info_plus`, for the version and build number on every platform the app ships.
