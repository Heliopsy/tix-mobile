// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/data/update/play_feed.dart';
import 'package:tix_mobile/src/data/update/release_feed.dart';

/// What starting a Play update did.
enum PlayStart {
  /// Play's flexible in-app update started, or finished one installs now.
  flexible,

  /// The Play listing opened instead.
  listing,

  /// Nothing opened.
  none,
}

/// Google Play's in-app updates.
abstract interface class PlayUpdates implements PlayUpdateSource {
  /// Starts a flexible update where Play allows one, else opens the Play
  /// listing.
  Future<PlayStart> start();
}

/// [PlayUpdates] over `tix/play-update`, answered by the play flavour's
/// `PlayUpdate.kt`. The oss flavour's stand-in answers null to everything.
class ChannelPlayUpdates implements PlayUpdates {
  /// Talks over [channel].
  const ChannelPlayUpdates({
    this.channel = const MethodChannel('tix/play-update'),
  });

  /// The channel.
  final MethodChannel channel;

  @override
  Future<PlayUpdateInfo?> info() async {
    try {
      return PlayUpdateInfo.fromMap(
        await channel.invokeMethod<Object?>('info'),
      );
    } on PlatformException catch (e) {
      throw UpdateException(UpdateErrorKind.network, e.message ?? e.code);
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<PlayStart> start() async {
    try {
      final answer = await channel.invokeMethod<String>('start');
      return PlayStart.values.asNameMap()[answer] ?? PlayStart.none;
    } on PlatformException catch (e) {
      log('update: Play update not started: ${e.code}');
      return PlayStart.none;
    } on MissingPluginException {
      return PlayStart.none;
    }
  }
}

/// [PlayUpdates] in the headless engine, which has no Play channel: Play's
/// answer is the one the Android update worker put in [link].
class LinkPlayUpdates implements PlayUpdates {
  /// Reads Play's answer from [link].
  const LinkPlayUpdates(this.link);

  /// The `tixwidget://` link the background run started with.
  final Uri? link;

  @override
  Future<PlayUpdateInfo?> info() async => PlayUpdateInfo.fromUri(link);

  @override
  Future<PlayStart> start() async => PlayStart.none;
}

/// [PlayUpdates] where Play is never there.
class NoPlayUpdates implements PlayUpdates {
  /// Creates it.
  const NoPlayUpdates();

  @override
  Future<PlayUpdateInfo?> info() async => null;

  @override
  Future<PlayStart> start() async => PlayStart.none;
}
