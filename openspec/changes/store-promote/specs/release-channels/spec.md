# release-channels

## ADDED Requirements

### Requirement: Manual promotion to production

A workflow started by hand SHALL promote a released version to production: on Google Play the version code
release.yaml gave its tag moves from the internal track to production, and on the App Store the version's newest
processed TestFlight build is submitted for review. It SHALL take the store, the version (empty for the newest
published release), the Play rollout in percent and a dry run switch, and SHALL run on GitHub-hosted runners only.

#### Scenario: Staged rollout on Play

- **WHEN** the workflow runs for Google with version 0.15.0 and rollout 20, and `PLAY_RELEASE_STATUS` is
  `completed`
- **THEN** version code 15000 goes from the internal track to production for 20% of users

#### Scenario: App Store submission

- **WHEN** the workflow runs for Apple with version 0.15.0 and TestFlight has processed builds of it
- **THEN** the newest of them is attached to App Store version 0.15.0 and submitted for review

### Requirement: Promotion dry run changes nothing

A dry run SHALL check the store credentials and that the build exists, print what would be promoted, and change
nothing in either store. A version with nothing to promote SHALL be a warning on a dry run and a failure on a
real run. A store whose secrets are missing SHALL be skipped as release.yaml skips it.

#### Scenario: Nothing on the internal track yet

- **WHEN** a dry run asks for a version whose version code is not on Play's internal track
- **THEN** the Google job warns that there is nothing to promote and succeeds

#### Scenario: Real run without a build

- **WHEN** a real run asks for a version with no processed TestFlight build
- **THEN** the Apple job fails and nothing is submitted
