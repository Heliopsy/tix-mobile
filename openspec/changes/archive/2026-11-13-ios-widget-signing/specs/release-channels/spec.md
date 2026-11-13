## ADDED Requirements

### Requirement: The TestFlight IPA carries the signed widget extension

The signed IPA SHALL embed the widget extension `red.tix.tixMobile.TixWidgets`, signed with its own App Store
profile, and the app and the extension SHALL both be signed with the App Group `group.red.tix.tixMobile`. The
TestFlight channel SHALL need the extension's profile secret `IOS_WIDGETS_PROFILE_BASE64` like the app's.

#### Scenario: Both bundles signed

- **WHEN** a release runs with every iOS secret set
- **THEN** the uploaded IPA holds `TixWidgets.appex`, and it and the app are signed for their bundle ids with
  `group.red.tix.tixMobile`

#### Scenario: Widget profile missing

- **WHEN** every other iOS secret is set but `IOS_WIDGETS_PROFILE_BASE64` is not
- **THEN** the iOS job builds unsigned and warns that `IOS_WIDGETS_PROFILE_BASE64` is missing

#### Scenario: Profile without the App Group

- **WHEN** either profile lacks `group.red.tix.tixMobile` or is for another bundle id
- **THEN** the signed build fails before building, naming the profile
