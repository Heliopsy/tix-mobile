// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/platform/deep_links.dart';
import 'package:tix_mobile/src/data/models/sso.dart';
import 'package:url_launcher/url_launcher.dart';

part 'sso_browser.g.dart';

/// The external user agent a provider sign-in runs in: never a WebView
/// inside the app.
abstract interface class SsoBrowser {
  /// Whether this platform has one.
  bool get supported;

  /// Opens [url] and answers the `red.tix.mobile:` redirect it ends with,
  /// or null when the person gave up.
  Future<Uri?> authenticate(Uri url);

  /// Gives up on the sign-in under way; its [authenticate] answers null.
  Future<void> cancel();
}

/// ASWebAuthenticationSession on iOS and macOS, Custom Tabs on Android and
/// the default browser on Linux and Windows, where the redirect comes back
/// through the scheme handler and [DeepLinkIntake].
class PlatformSsoBrowser implements SsoBrowser {
  /// Hears redirects through [intake] and opens the browser with [launch].
  PlatformSsoBrowser(this.intake, {this.launch = _launch});

  /// Where scheme handler redirects arrive.
  final DeepLinkIntake intake;

  /// Opens an address in the browser, false when none would.
  final Future<bool> Function(Uri url) launch;

  static const _channel = MethodChannel('tix/sso');

  /// How long Android waits for a redirect once the app is back in front,
  /// before counting the return as a cancel.
  static const _resumeGrace = Duration(seconds: 2);

  Completer<Uri?>? _waiting;

  bool get _session => Platform.isIOS || Platform.isMacOS;

  @override
  bool get supported =>
      _session || Platform.isAndroid || Platform.isLinux || Platform.isWindows;

  @override
  Future<Uri?> authenticate(Uri url) async {
    if (_session) return await _viaSession(url);
    await cancel();
    final waiting = _waiting = Completer<Uri?>();
    final redirects = intake.ssoRedirects.listen(_complete);
    Timer? grace;
    final lifecycle = Platform.isAndroid
        ? AppLifecycleListener(
            onResume: () {
              grace?.cancel();
              grace = Timer(_resumeGrace, () => _complete(null));
            },
          )
        : null;
    try {
      if (Platform.isWindows) await _registerWindowsScheme();
      final opened = await launch(url);
      if (!opened) throw const TixException(TixErrorKind.ssoFailed);
      return await waiting.future;
    } finally {
      grace?.cancel();
      lifecycle?.dispose();
      await redirects.cancel();
      if (identical(_waiting, waiting)) _waiting = null;
    }
  }

  /// Custom Tabs where a browser offers them, never url_launcher's WebView
  /// fallback; the browser itself otherwise.
  static Future<bool> _launch(Uri url) async => await launchUrl(
    url,
    mode:
        Platform.isAndroid &&
            await supportsLaunchMode(LaunchMode.inAppBrowserView)
        ? LaunchMode.inAppBrowserView
        : LaunchMode.externalApplication,
  );

  void _complete(Uri? redirect) {
    final waiting = _waiting;
    if (waiting != null && !waiting.isCompleted) waiting.complete(redirect);
  }

  Future<Uri?> _viaSession(Uri url) async {
    try {
      final answer = await _channel.invokeMethod<String>('authenticate', {
        'url': url.toString(),
        'scheme': ssoScheme,
      });
      return answer == null ? null : Uri.tryParse(answer);
    } on PlatformException catch (e) {
      if (e.code == 'cancelled') return null;
      throw TixException(TixErrorKind.ssoFailed, message: e.message ?? '');
    }
  }

  @override
  Future<void> cancel() async {
    if (_session) {
      await _channel.invokeMethod<void>('cancel');
      return;
    }
    _complete(null);
  }

  /// Points the per-user `red.tix.mobile` URL class at this executable,
  /// which hands the redirect to the running app. Windows has no installer
  /// to declare it, and the current user's classes need no elevation.
  static Future<void> _registerWindowsScheme() async {
    const key = r'HKCU\Software\Classes\' + ssoScheme;
    final exe = Platform.resolvedExecutable;
    for (final args in [
      ['add', key, '/ve', '/d', 'URL:tix sign-in', '/f'],
      ['add', key, '/v', 'URL Protocol', '/d', '', '/f'],
      ['add', '$key\\shell\\open\\command', '/ve', '/d', '"$exe" "%1"', '/f'],
    ]) {
      await Process.run('reg', args);
    }
  }
}

/// The platform's user agent for provider sign-ins; tests swap in a fake.
@Riverpod(keepAlive: true)
SsoBrowser ssoBrowser(Ref ref) =>
    PlatformSsoBrowser(ref.watch(deepLinkIntakeProvider));
