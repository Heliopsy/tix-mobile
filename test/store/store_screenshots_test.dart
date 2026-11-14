// SPDX-License-Identifier: AGPL-3.0-or-later

/// Store screenshots, drawn from the real app against a fictional team on an
/// in-memory tix server, at each store's pixel size, as 24-bit PNGs.
///
/// Tagged `screenshots`, which dart_test.yaml skips. `just store-screenshots`
/// runs it and writes:
///
/// - `fastlane/metadata/android/en-US/images/phoneScreenshots/1.png` ... (1080x1920)
/// - `fastlane/metadata/android/en-US/images/featureGraphic.png` (1024x500)
/// - `fastlane/screenshots/en-US/iphone-1.png` ... (1320x2868, 6.9")
/// - `fastlane/screenshots/en-US/ipad-1.png` ... (2064x2752, 13")
@Tags(['screenshots'])
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/app.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/data/events/event_stream.dart';
import 'package:tix_mobile/src/features/tasks/application/screen.dart';

import '../helpers/app.dart';
import '../helpers/fake_events.dart';
import 'demo_team.dart';

const _play = 'fastlane/metadata/android/en-US/images';
const _apple = 'fastlane/screenshots/en-US';

/// One store's screenshot format.
class _Device {
  const _Device({
    required this.name,
    required this.pixels,
    required this.ratio,
    required this.top,
    required this.bottom,
    required this.bar,
  });

  final String name;

  /// The PNG's size in pixels.
  final Size pixels;
  final double ratio;

  /// The system bars' heights, in logical pixels.
  final double top;
  final double bottom;
  final _Bar bar;

  Size get logical => pixels / ratio;

  String path(int n) => switch (bar) {
    _Bar.android => '$_play/phoneScreenshots/$n.png',
    _ => '$_apple/$name-$n.png',
  };
}

enum _Bar { android, iphone, ipad }

/// Google Play phone: 1080x1920, a 411 dp wide phone.
const _android = _Device(
  name: 'phone',
  pixels: Size(1080, 1920),
  ratio: 2.625,
  top: 24,
  bottom: 20,
  bar: _Bar.android,
);

/// App Store iPhone 6.9": 1320x2868 at @3x, 440 by 956 points.
const _iphone = _Device(
  name: 'iphone',
  pixels: Size(1320, 2868),
  ratio: 3,
  top: 62,
  bottom: 34,
  bar: _Bar.iphone,
);

/// App Store iPad 13": 2064x2752 at @2x, 1032 by 1376 points.
const _ipad = _Device(
  name: 'ipad',
  pixels: Size(2064, 2752),
  ratio: 2,
  top: 24,
  bottom: 20,
  bar: _Bar.ipad,
);

/// One screenshot: the theme, where the app goes, and what is done there.
class _Shot {
  const _Shot(this.name, {required this.dark, required this.go, this.act});

  final String name;
  final bool dark;
  final String Function(_Device d) go;
  final Future<void> Function(
    WidgetTester tester,
    ProviderContainer c,
    _Device d,
  )?
  act;
}

final _shots = <_Shot>[
  _Shot(
    'board',
    dark: false,
    go: (d) => d.bar == _Bar.ipad
        ? Routes.task('app', 'app-12')
        : Routes.project('app'),
    act: (tester, c, d) async {
      if (d.bar != _Bar.ipad) return;
      c
          .read(taskScreenProvider(const ProjectScope('app')).notifier)
          .setView(TaskView.board);
    },
  ),
  _Shot(
    'task',
    dark: true,
    go: (d) => Routes.task('app', 'app-12'),
    act: (tester, c, d) async {
      final comment = find.textContaining('The queue works on Android');
      await tester.scrollUntilVisible(
        comment,
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await Scrollable.ensureVisible(
        tester.element(find.byKey(const Key('activity.tabs'))),
      );
      await _settle(tester);
    },
  ),
  _Shot(
    'search',
    dark: false,
    go: (d) => Routes.tasks,
    act: (tester, c, d) async {
      c
          .read(taskScreenProvider(const AllScope()).notifier)
          .setExpression('tag:release');
      await _settle(tester);
      if (d.bar == _Bar.ipad) {
        await tester.tap(find.text('Build cache for the release pipeline'));
      }
    },
  ),
  _Shot(
    'create',
    dark: true,
    go: (d) => Routes.project('app'),
    act: (tester, c, d) async {
      await tester.tap(find.text('New task').first);
      await _settle(tester);
      await tester.tap(find.byKey(const Key('quickAdd.details')));
      await _settle(tester);
      Future<void> type(String key, String text) async {
        await tester.enterText(find.byKey(Key('addDetails.$key')), text);
        await tester.pump();
      }

      await type('title', 'Beta feedback round for 2.4');
      await type(
        'body',
        'Collect crash reports and notes from the beta group, then file '
            'one task per issue before the release call on Friday.',
      );
      await type('assignee', 'mira');
      await type('tags', 'release, ios, android');
      await tester.ensureVisible(find.byKey(const Key('addDetails.priority')));
      await _settle(tester);
      await tester.tap(find.byKey(const Key('addDetails.priority')));
      await _settle(tester);
      await tester.tap(find.text('High').last);
      await _settle(tester);
      await tester.ensureVisible(find.byKey(const Key('addDetails.due')));
      await _settle(tester);
      await tester.tap(find.byKey(const Key('addDetails.due')));
      await _settle(tester);
      await tester.tap(find.text('13').last);
      await tester.pump();
      await tester.tap(find.text('OK').last);
      await _settle(tester);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.ensureVisible(find.byKey(const Key('addDetails.title')));
      await _settle(tester);
    },
  ),
  _Shot(
    'switcher',
    dark: false,
    go: (d) => Routes.inbox,
    act: (tester, c, d) async {
      final title = find.byKey(const Key('switcher.title'));
      await tester.tap(
        title.evaluate().isEmpty
            ? find.byKey(const Key('switcher.open')).first
            : title.first,
      );
      await _settle(tester);
    },
  ),
  _Shot('settings', dark: true, go: (d) => Routes.settings),
];

/// A live-updates socket that accepts every subscription.
class _LiveSocket extends FakeSocket {
  _LiveSocket(super.url, super.headers);

  @override
  void send(String text) {
    super.send(text);
    final msg = jsonDecode(text) as Map<String, Object?>;
    if (msg['type'] == 'subscribe') {
      scheduleMicrotask(() => push({'type': 'subscribed', 'id': msg['id']}));
    }
  }
}

Future<EventSocket> _live(Uri url, Map<String, String> headers) async =>
    _LiveSocket(url, headers);

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// The phone's status bar and the gesture handle, over the app.
class _SystemBars extends StatelessWidget {
  const _SystemBars(this.device, {required this.dark});

  final _Device device;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final ink = dark ? const Color(0xFFF2F2F2) : const Color(0xFF111111);
    final ios = device.bar != _Bar.android;
    final time = TextStyle(
      fontFamily: 'Roboto',
      fontSize: switch (device.bar) {
        _Bar.iphone => 17,
        _Bar.ipad => 14,
        _Bar.android => 13,
      },
      fontWeight: ios ? FontWeight.w600 : FontWeight.w500,
      color: ink,
    );
    final icon = device.bar == _Bar.iphone ? 18.0 : 15.0;
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: device.top,
            child: Padding(
              padding: switch (device.bar) {
                _Bar.iphone => const EdgeInsets.fromLTRB(46, 18, 36, 0),
                _Bar.ipad => const EdgeInsets.fromLTRB(22, 4, 20, 0),
                _Bar.android => const EdgeInsets.fromLTRB(18, 2, 16, 0),
              },
              child: Row(
                children: [
                  Text(
                    device.bar == _Bar.ipad ? '9:41  Thu 12 Nov' : '9:41',
                    style: time,
                  ),
                  const Spacer(),
                  Icon(Icons.signal_cellular_alt, size: icon, color: ink),
                  const SizedBox(width: 4),
                  Icon(Icons.wifi, size: icon, color: ink),
                  const SizedBox(width: 4),
                  Icon(
                    ios ? Icons.battery_full : Icons.battery_6_bar,
                    size: icon + 2,
                    color: ink,
                  ),
                ],
              ),
            ),
          ),
          if (device.bar == _Bar.iphone)
            Positioned(
              top: 11,
              left: (device.logical.width - 126) / 2,
              width: 126,
              height: 37,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF000000),
                  borderRadius: BorderRadius.all(Radius.circular(19)),
                ),
              ),
            ),
          Positioned(
            bottom: device.bar == _Bar.android ? 8 : 8,
            left: (device.logical.width - (ios ? 140 : 108)) / 2,
            width: ios ? 140 : 108,
            height: ios ? 5 : 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: ink,
                borderRadius: const BorderRadius.all(Radius.circular(3)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _shoot(
  WidgetTester tester,
  _Device device,
  _Shot shot,
  int n,
) async {
  final server = demoTeam();
  final stores = signInStores(
    server,
    tenant: 'lumen',
    tenants: const ['lumen', 'garden', 'home'],
  );
  stores.settings.values['settings.theme'] = shot.dark ? 'dark' : 'light';
  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            ProviderScope(
              key: ValueKey('${device.name}-${shot.name}'),
              overrides: fakeOverrides(
                server,
                settings: stores.settings,
                secrets: stores.secrets,
                events: _live,
                clock: () => demoNow,
              ),
              child: const App(),
            ),
            _SystemBars(device, dark: shot.dark),
          ],
        ),
      ),
    ),
  );
  await _settle(tester);
  final c = ProviderScope.containerOf(tester.element(find.byType(App)));
  c.read(routerProvider).go(shot.go(device));
  await _settle(tester);
  await shot.act?.call(tester, c, device);
  await _settle(tester);
  await _capture(tester, key, device, device.path(n));
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
}

Future<void> _capture(
  WidgetTester tester,
  GlobalKey key,
  _Device device,
  String path,
) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: device.ratio);
    expect(
      Size(image.width.toDouble(), image.height.toDouble()),
      device.pixels,
      reason: path,
    );
    await _writePng(image, path);
  });
}

/// Writes [image] as a 24-bit RGB PNG: both stores refuse an alpha channel
/// and dart:ui only encodes RGBA.
Future<void> _writePng(ui.Image image, String path) async {
  final rgba = (await image.toByteData())!.buffer.asUint8List();
  final w = image.width;
  final h = image.height;
  final raw = Uint8List(h * (w * 3 + 1));
  var o = 0;
  for (var y = 0; y < h; y++) {
    raw[o++] = 0;
    for (var x = 0; x < w; x++) {
      final i = (y * w + x) * 4;
      raw[o++] = rgba[i];
      raw[o++] = rgba[i + 1];
      raw[o++] = rgba[i + 2];
    }
  }
  final header = ByteData(13)
    ..setUint32(0, w)
    ..setUint32(4, h)
    ..setUint8(8, 8)
    ..setUint8(9, 2);
  final out = BytesBuilder()
    ..add(const [137, 80, 78, 71, 13, 10, 26, 10])
    ..add(_chunk('IHDR', header.buffer.asUint8List()))
    ..add(_chunk('IDAT', ZLibEncoder(level: 9).convert(raw)))
    ..add(_chunk('IEND', const []));
  File(path)
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(out.takeBytes());
}

List<int> _chunk(String type, List<int> data) {
  final body = [...ascii.encode(type), ...data];
  final len = ByteData(4)..setUint32(0, data.length);
  final crc = ByteData(4)..setUint32(0, _crc32(body));
  return [...len.buffer.asUint8List(), ...body, ...crc.buffer.asUint8List()];
}

final _crcTable = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc32(List<int> bytes) {
  var c = 0xFFFFFFFF;
  for (final b in bytes) {
    c = _crcTable[(c ^ b) & 0xFF] ^ (c >> 8);
  }
  return c ^ 0xFFFFFFFF;
}

/// The Play feature graphic: the app icon and name on tix's teal.
class _FeatureGraphic extends StatelessWidget {
  const _FeatureGraphic(this.icon);

  final ui.Image icon;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.ltr,
    child: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F766E), Color(0xFF0B4F4A)],
        ),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(52)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x55000000),
                    blurRadius: 36,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: RawImage(image: icon, width: 220, height: 220),
            ),
            const SizedBox(width: 48),
            const Text(
              'tix',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 150,
                height: 1,
                fontWeight: FontWeight.w700,
                letterSpacing: -3,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  final only = Platform.environment['SHOTS'];
  testWidgets('feature graphic', (tester) async {
    debugDisableShadows = false;
    tester.view
      ..physicalSize = const Size(1024, 500)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final icon = (await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(
        File('assets/branding/icon-1024.png').readAsBytesSync(),
      );
      return (await codec.getNextFrame()).image;
    }))!;
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(key: key, child: _FeatureGraphic(icon)),
    );
    await tester.pump();
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage();
      expect(image.width, 1024);
      expect(image.height, 500);
      await _writePng(image, '$_play/featureGraphic.png');
    });
    debugDisableShadows = true;
  });

  for (final device in [_android, _iphone, _ipad]) {
    testWidgets('${device.name} screenshots', (tester) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTouch;
      debugDisableShadows = false;
      tester.view
        ..physicalSize = device.pixels
        ..devicePixelRatio = device.ratio
        ..padding = FakeViewPadding(
          top: device.top * device.ratio,
          bottom: device.bottom * device.ratio,
        )
        ..viewPadding = FakeViewPadding(
          top: device.top * device.ratio,
          bottom: device.bottom * device.ratio,
        );
      addTearDown(tester.view.reset);
      for (final (i, shot) in _shots.indexed) {
        if (only != null && !only.split(',').contains(shot.name)) continue;
        await _shoot(tester, device, shot, i + 1);
      }
      debugDisableShadows = true;
    }, timeout: const Timeout(Duration(minutes: 10)));
  }
}
