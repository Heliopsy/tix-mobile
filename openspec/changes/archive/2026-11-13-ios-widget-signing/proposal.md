# Sign the widget extension for TestFlight

## Why

The iOS app embeds the home screen widget extension `TixWidgets` (`red.tix.tixMobile.TixWidgets`), which needs its
own App Store profile carrying the App Group `group.red.tix.tixMobile`. The `ios ipa` lane installed one profile and
signed only `Runner`, so a release with the iOS secrets set could not export an App Store IPA.

## What Changes

- A new secret, `IOS_WIDGETS_PROFILE_BASE64`, the extension's App Store profile. The TestFlight channel runs only
  when it is set with the others.
- The `ios ipa` lane installs both profiles, checks each is an App Store profile for the team, its bundle id and
  the App Group, signs `Runner` and `TixWidgets` manually with their own profile, and maps both bundle ids in the
  export options.
- The lane fails unless the IPA holds the extension and both bundles are signed with the App Group.
- `docs/releasing.md` lists the new secret and the App Group setup.
