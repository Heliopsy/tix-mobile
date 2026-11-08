# Proposal

## Why

Every platform still shows Flutter's default icon and most show the project name `tix_mobile`. The app
should look like tix wherever it appears: the launcher, the dock, the window, the splash screen and its own
screens, matching the mark the tix web app uses as its favicon and logo.

## What Changes

- Render every icon from `assets/branding/mark.svg` with `scripts/icons.sh` (`just icons`), committing the
  1024 px masters it makes.
- Launcher icons on Android (legacy, adaptive with monochrome), iOS (with iOS 18 dark and tinted variants),
  macOS (Apple's inset template), Windows (multi-size `.ico`) and Linux (window icon, hicolor icons and a
  `.desktop` entry shipped in the bundle).
- Android and iOS launch screens: the mark on tix's page background, light and dark.
- The user-visible name is `tix` on every platform.
- The mark heads the connect screen, and Settings gains an About entry showing it.

## Impact

- New dev dependencies: `flutter_launcher_icons` and `flutter_native_splash`, generators only.
- New capability: `app-branding`.
