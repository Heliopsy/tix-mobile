# Tasks

## 1. Spec

- [x] 1.1 `release-channels` delta

## 2. Lanes

- [x] 2.1 `android promote`: internal to production by version code, rollout, `PLAY_RELEASE_STATUS`, dry run
  through Play's validate-only edit
- [x] 2.2 `ios promote`: newest processed TestFlight build of the version, submitted for review, dry run that
  only reads

## 3. Workflow and docs

- [x] 3.1 `promote.yaml` on GitHub-hosted runners, skipping a store without its secrets
- [x] 3.2 `docs/releasing.md` and the README
