// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tix_mobile/src/core/platform/dav_profile.dart';
import 'package:tix_mobile/src/core/platform/profile_server.dart';
import 'package:tix_mobile/src/core/update/updates.dart' show playBuild;
import 'package:url_launcher/url_launcher.dart';

export 'package:tix_mobile/src/core/platform/dav_profile.dart';

part 'dav_handoff.g.dart';

/// How this platform hands a CalDAV account to another app.
enum DavPlatform {
  /// A configuration profile Safari downloads, for Reminders.
  ios,

  /// A configuration profile System Settings opens, for Reminders.
  macos,

  /// DAVx5's login, filled in, or the details and store links.
  android,

  /// The details, for Thunderbird or Evolution.
  linux,

  /// The details, for Thunderbird.
  windows,

  /// The details alone.
  other,
}

/// How a copied password was marked.
enum ClipMark {
  /// Local to this device and cleared after 2 minutes (iOS).
  expires,

  /// Hidden in the clipboard preview (Android).
  hidden,

  /// Copied as any text; the person should clear it after pasting.
  plain,
}

/// A profile opened in the system: whether it went, and, for one served to
/// Safari, whether Safari fetched it.
class ProfileOpening {
  /// [opened] says the system took it; [served] completes once Safari
  /// fetched it (true) or the server closed unserved (false).
  ProfileOpening({required this.opened, Future<bool>? served})
    : served = served ?? Future.value(opened);

  /// Whether the browser or System Settings was opened.
  final bool opened;

  /// Whether the profile reached the system.
  final Future<bool> served;
}

/// Where DAVx5 and a task app are installed from.
class DavStoreLinks {
  /// The three pages.
  const DavStoreLinks({
    required this.davx5,
    required this.tasksOrg,
    required this.jtx,
  });

  /// DAVx5, which does the syncing.
  final Uri davx5;

  /// tasks.org, which shows the tasks.
  final Uri tasksOrg;

  /// jtx Board, which shows the tasks.
  final Uri jtx;
}

/// DAVx5's package, the same in its F-Droid and Google Play builds.
const davx5Package = 'at.bitfire.davdroid';

/// The store pages: Google Play in the [play] build, F-Droid otherwise.
DavStoreLinks davStoreLinks({required bool play}) {
  Uri page(String id) => play
      ? Uri.https('play.google.com', '/store/apps/details', {'id': id})
      : Uri.https('f-droid.org', '/packages/$id/');
  return DavStoreLinks(
    davx5: page(davx5Package),
    tasksOrg: page('org.tasks'),
    jtx: page('at.techbee.jtx'),
  );
}

/// Hands a CalDAV account to another app on this device. One setup sheet
/// uses it at a time and calls [cleanUp] when it closes. Nothing here logs
/// its arguments.
abstract interface class DavHandoff {
  /// Which hand-off this platform has.
  DavPlatform get platform;

  /// Where DAVx5 and the task apps come from in this build.
  DavStoreLinks get storeLinks;

  /// Whether DAVx5 is installed (Android only).
  Future<bool> davx5Installed();

  /// Opens DAVx5's login filled in with [account]; false when it would not
  /// open.
  Future<bool> openDavx5(DavAccount account);

  /// Opens [profile] in the system: served to Safari on iOS, written to a
  /// temporary file for System Settings on macOS.
  Future<ProfileOpening> openProfile(String profile);

  /// Offers [profile] as a file through the share sheet, for Save to Files.
  Future<bool> saveProfile(String profile, {Rect? origin});

  /// Copies the app password [value], marked as sensitive where the
  /// platform can.
  Future<ClipMark> copySecret(String value);

  /// Stops serving and deletes every profile file written.
  Future<void> cleanUp();
}

/// [DavHandoff] for the platform the app runs on, over `tix/dav` where it
/// needs native code.
class PlatformDavHandoff implements DavHandoff {
  /// Creates the service.
  PlatformDavHandoff({
    Future<bool> Function(Uri url)? launch,
    Future<Directory> Function()? tempDir,
    DavPlatform? platform,
  }) : _launch = launch ?? _launchExternal,
       _tempDir = tempDir ?? getTemporaryDirectory,
       platform = platform ?? _current();

  static const _channel = MethodChannel('tix/dav');
  final Future<bool> Function(Uri url) _launch;
  final Future<Directory> Function() _tempDir;
  ProfileServer? _server;

  @override
  final DavPlatform platform;

  @override
  DavStoreLinks get storeLinks => davStoreLinks(play: playBuild);

  static DavPlatform _current() {
    if (Platform.isIOS) return DavPlatform.ios;
    if (Platform.isMacOS) return DavPlatform.macos;
    if (Platform.isAndroid) return DavPlatform.android;
    if (Platform.isLinux) return DavPlatform.linux;
    if (Platform.isWindows) return DavPlatform.windows;
    return DavPlatform.other;
  }

  static Future<bool> _launchExternal(Uri url) =>
      launchUrl(url, mode: LaunchMode.externalApplication);

  @override
  Future<bool> davx5Installed() async {
    if (platform != DavPlatform.android) return false;
    try {
      return await _channel.invokeMethod<bool>('davx5Installed') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> openDavx5(DavAccount account) async {
    if (platform != DavPlatform.android) return false;
    try {
      return await _channel.invokeMethod<bool>(
            'openDavx5',
            davx5Arguments(account),
          ) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<ProfileOpening> openProfile(String profile) async {
    switch (platform) {
      case DavPlatform.ios:
        await _server?.close();
        final server = _server = await ProfileServer.start(profile);
        await _background('beginBackgroundTask');
        unawaited(
          server.served.whenComplete(() => _background('endBackgroundTask')),
        );
        final opened = await _launch(server.url);
        if (!opened) await server.close();
        return ProfileOpening(opened: opened, served: server.served);
      case DavPlatform.macos:
        final file = await _write(profile);
        return ProfileOpening(opened: await _launch(Uri.file(file.path)));
      case DavPlatform.android:
      case DavPlatform.linux:
      case DavPlatform.windows:
      case DavPlatform.other:
        return ProfileOpening(opened: false);
    }
  }

  Future<void> _background(String method) => _call(method);

  /// Whether [method] ran on the native side.
  Future<bool> _call(String method, [Map<String, String>? arguments]) async {
    try {
      await _channel.invokeMethod<void>(method, arguments);
      return true;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> saveProfile(String profile, {Rect? origin}) async {
    final file = await _write(profile);
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/x-apple-aspen-config')],
        sharePositionOrigin: origin,
      ),
    );
    return result.status == ShareResultStatus.success;
  }

  Future<Directory> _profileDir() async =>
      Directory('${(await _tempDir()).path}/tix-dav');

  Future<File> _write(String profile) async {
    final dir = await _profileDir();
    if (dir.existsSync()) await dir.delete(recursive: true);
    await dir.create(recursive: true);
    final file = File('${dir.path}/tix.mobileconfig');
    await file.writeAsString(profile, flush: true);
    return file;
  }

  @override
  Future<ClipMark> copySecret(String value) async {
    final mark = switch (platform) {
      DavPlatform.ios => ClipMark.expires,
      DavPlatform.android => ClipMark.hidden,
      _ => null,
    };
    if (mark != null && await _call('copySensitive', {'text': value})) {
      return mark;
    }
    await Clipboard.setData(ClipboardData(text: value));
    return ClipMark.plain;
  }

  @override
  Future<void> cleanUp() async {
    final server = _server;
    _server = null;
    await server?.close();
    final dir = await _profileDir();
    if (dir.existsSync()) await dir.delete(recursive: true);
  }
}

/// What `tix/dav` `openDavx5` is sent for [account]: the DAVx5 address, with
/// no user info, and the user name and password as separate arguments that
/// become intent extras.
Map<String, String> davx5Arguments(DavAccount account) => {
  'address': davx5Address(account.url),
  'username': account.username,
  'password': account.password,
};

/// The platform's hand-off; tests swap in a fake.
@Riverpod(keepAlive: true)
DavHandoff davHandoff(Ref ref) => PlatformDavHandoff();
