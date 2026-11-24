// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/platform/deep_links.dart';
import 'package:tix_mobile/src/data/models/sso.dart';
import 'package:url_launcher/url_launcher.dart';

part 'sso_browser.g.dart';

/// Runs a command and answers how it went, as [Process.run] does.
typedef ProcessRunner = Future<ProcessResult> Function(
  String executable,
  List<String> arguments,
);

/// The external user agent a provider sign-in runs in: never a WebView
/// inside the app.
abstract interface class SsoBrowser {
  /// Whether this platform has one that hands the redirect back.
  Future<bool> supported();

  /// Opens [attempt]'s address and answers the `red.tix.mobile:` redirect
  /// that carries its state, or null when the person gave up. A redirect
  /// with another state, such as one from an older tab, is ignored.
  Future<Uri?> authenticate(SsoAttempt attempt);

  /// Gives up on the sign-in under way; its [authenticate] answers null.
  Future<void> cancel();

  /// The redirect that arrived while no sign-in waited, such as the one
  /// that restarted the app, while its code still lasts; null otherwise.
  Future<Uri?> leftOver();
}

/// ASWebAuthenticationSession on iOS and macOS, Custom Tabs on Android and
/// the default browser on Linux and Windows, where the redirect comes back
/// through the scheme handler and [DeepLinkIntake].
class PlatformSsoBrowser implements SsoBrowser {
  /// Hears redirects through [intake], opens the browser with [launch] and
  /// runs `xdg-mime` and `reg` with [run]. A desktop sign-in fails after
  /// [desktopWait].
  PlatformSsoBrowser(
    this.intake, {
    this.launch = _launch,
    this.run = Process.run,
    Map<String, String>? environment,
    this.desktopWait = const Duration(minutes: 5),
  }) : environment = environment ?? Platform.environment;

  /// Where scheme handler redirects arrive.
  final DeepLinkIntake intake;

  /// Opens an address in the browser, false when none would.
  final Future<bool> Function(Uri url) launch;

  /// Runs a desktop command.
  final ProcessRunner run;

  /// The process environment, read for a Flatpak sandbox.
  final Map<String, String> environment;

  /// How long Linux and Windows wait for the browser to hand back.
  final Duration desktopWait;

  static const _channel = MethodChannel('tix/sso');

  /// How long Android waits for a redirect once the app is back in front,
  /// before counting the return as a cancel. A slow phone can take seconds
  /// between showing the app and handing it the redirect.
  static const _resumeGrace = Duration(seconds: 5);

  Completer<Uri?>? _waiting;

  bool get _session => Platform.isIOS || Platform.isMacOS;

  bool get _desktop => Platform.isLinux || Platform.isWindows;

  @override
  Future<bool> supported() async {
    if (_session || Platform.isAndroid || Platform.isWindows) return true;
    return Platform.isLinux && await linuxHandlerRegistered();
  }

  /// Whether the desktop hands `red.tix.mobile:` links to an app: a Flatpak
  /// exports its desktop entry with the handler, and elsewhere `xdg-mime`
  /// names the entry that declares it. Without one the browser's redirect
  /// would go nowhere.
  @visibleForTesting
  Future<bool> linuxHandlerRegistered() async {
    if (environment.containsKey('FLATPAK_ID')) return true;
    try {
      final answer = await run('xdg-mime', [
        'query',
        'default',
        'x-scheme-handler/$ssoScheme',
      ]);
      return answer.exitCode == 0 && '${answer.stdout}'.trim().isNotEmpty;
    } on ProcessException {
      return false;
    }
  }

  @override
  Future<Uri?> authenticate(SsoAttempt attempt) async {
    if (_session) return await _viaSession(attempt.url);
    await cancel();
    final waiting = _waiting = Completer<Uri?>();
    final redirects = intake.ssoRedirects
        .where((r) => ssoStateOf(r) == attempt.state)
        .listen(_complete);
    Timer? grace;
    final lifecycle = Platform.isAndroid
        ? AppLifecycleListener(
            onResume: () {
              grace?.cancel();
              grace = Timer(_resumeGrace, () => _complete(null));
            },
          )
        : null;
    final deadline = _desktop
        ? Timer(desktopWait, () {
            if (!waiting.isCompleted) {
              waiting.completeError(
                const TixException(TixErrorKind.ssoExpired),
              );
            }
          })
        : null;
    try {
      if (Platform.isWindows) await registerWindowsScheme();
      final opened = await launch(attempt.url);
      if (!opened) throw const TixException(TixErrorKind.ssoFailed);
      return await waiting.future;
    } finally {
      grace?.cancel();
      deadline?.cancel();
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

  @override
  Future<Uri?> leftOver() async {
    await intake.start();
    return intake.takeSso(within: ssoCodeLifetime);
  }

  /// Points the per-user `red.tix.mobile` URL class at this executable,
  /// which hands the redirect to the running app. Windows has no installer
  /// to declare it, and the current user's classes need no elevation. A
  /// key `reg` will not write fails the sign-in before the browser opens.
  @visibleForTesting
  Future<void> registerWindowsScheme() async {
    const key = r'HKCU\Software\Classes\' + ssoScheme;
    final exe = Platform.resolvedExecutable;
    for (final args in [
      ['add', key, '/ve', '/d', 'URL:tix sign-in', '/f'],
      ['add', key, '/v', 'URL Protocol', '/d', '', '/f'],
      ['add', '$key\\shell\\open\\command', '/ve', '/d', '"$exe" "%1"', '/f'],
    ]) {
      final ProcessResult answer;
      try {
        answer = await run('reg', args);
      } on ProcessException {
        throw const TixException(TixErrorKind.ssoFailed);
      }
      if (answer.exitCode != 0) {
        throw const TixException(TixErrorKind.ssoFailed);
      }
    }
  }
}

/// The platform's user agent for provider sign-ins; tests swap in a fake.
@Riverpod(keepAlive: true)
SsoBrowser ssoBrowser(Ref ref) =>
    PlatformSsoBrowser(ref.watch(deepLinkIntakeProvider));
