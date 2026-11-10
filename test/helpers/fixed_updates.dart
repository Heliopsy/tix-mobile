// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/misc.dart';
import 'package:meta/meta.dart';
import 'package:tix_mobile/src/core/update/updates.dart';
import 'package:tix_mobile/src/data/update/installer.dart';
import 'package:tix_mobile/src/data/update/release.dart';

/// An update controller that holds a fixed state and records what it is
/// asked.
class FixedUpdates extends Updates {
  /// Holds [_initial].
  FixedUpdates(this._initial);

  final UpdateState _initial;

  /// How often Check now ran.
  @visibleForTesting
  int checks = 0;

  /// How often Restart to update ran.
  @visibleForTesting
  int restarts = 0;

  /// How often the app asked to install on quit.
  @visibleForTesting
  int quits = 0;

  @override
  UpdateState build() => _initial;

  @override
  Future<void> check() async => checks++;

  @override
  Future<bool> restart() async {
    restarts++;
    return true;
  }

  @override
  Future<void> installOnQuit() async => quits++;
}

/// An offer of [version] with its release page.
UpdateOffer offerOf(String version, {bool asset = true}) {
  final release = Release(
    tag: 'v$version',
    version: ReleaseVersion.tryParse(version)!,
    page: Uri.parse(
      'https://github.com/heliopsy/tix-mobile/releases/tag/v$version',
    ),
    assets: const [],
  );
  return UpdateOffer(
    release: release,
    asset: asset
        ? ReleaseAsset(
            name: 'tix-mobile-$version-linux-x64.tar.gz',
            url: Uri.parse('https://example.test/a.tar.gz'),
          )
        : null,
  );
}

/// A state with [version] staged.
UpdateState readyState(String version) => UpdateState(
  phase: UpdatePhase.ready,
  offer: offerOf(version),
  staged: StagedUpdate(
    version: ReleaseVersion.tryParse(version)!,
    path: '/opt/.tix.update',
  ),
);

/// The override that puts [updates] in place; the mode comes from
/// `fakeOverrides(updates: ...)`.
Override fixedUpdates(FixedUpdates updates) =>
    updatesProvider.overrideWith(() => updates);
