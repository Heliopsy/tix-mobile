// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/platform/app_info.dart';
import 'package:tix_mobile/src/data/local/local_engine.dart';
import 'package:tix_mobile/src/features/about/application/about.dart';

import '../../../helpers/app.dart';
import '../../../helpers/container.dart';
import '../../../helpers/fake_tix.dart';

const _app = AppInfo(
  version: '0.4.0',
  build: '12',
  platform: 'Android',
  osVersion: '15',
);

Diagnostics _facts({String? engine = 'v0.49.0', String? server = 'v1.2.3'}) =>
    Diagnostics(
      app: _app,
      engine: engine,
      server: server,
      serverAddress: 'https://tix.example',
      locale: 'de',
    );

void main() {
  test('diagnostics leave the server address out unless asked', () {
    final d = _facts();
    expect(d.appVersion, '0.4.0 (12)');
    expect(d.toText(), '''
tix-mobile 0.4.0 (12)
Platform: Android 15
Engine: v0.49.0
Server: v1.2.3
Locale: de''');
    expect(d.toText(), isNot(contains('tix.example')));
    expect(
      d.toText(withServerAddress: true),
      contains('Server address: https://tix.example'),
    );
    expect(
      _facts(engine: null, server: null).toText(),
      allOf(contains('Engine: none'), contains('Server: unknown')),
    );
  });

  test('the bug report fills in the form fields it knows', () {
    final uri = _facts().bugReport();
    expect(uri.path, '/heliopsy/tix-mobile/issues/new');
    expect(uri.queryParameters, {
      'template': 'bug_report.yml',
      'platform': 'Android',
      'os-version': 'Android 15',
      'app-version': '0.4.0 (12)',
      'server-version': 'v1.2.3',
      'logs': _facts().toText(),
    });
    expect(
      _facts(server: null).bugReport().queryParameters,
      isNot(contains('server-version')),
    );
  });

  test('platform names match the bug form', () {
    expect(platformName('ios'), 'iOS');
    expect(platformName('macos'), 'macOS');
    expect(platformName('fuchsia'), 'fuchsia');
  });

  test('versions come from the engine and the active server', () async {
    final c = makeContainer(fakeOverrides(FakeTix(), local: true));
    expect(await c.read(engineVersionProvider.future), 'in-memory');
    expect(await c.read(serverVersionProvider.future), isNull);
    expect(c.read(serverAddressProvider), '');

    final none = makeContainer(
      fakeOverrides(FakeTix(), engine: const UnavailableLocalTixEngine()),
    );
    expect(await none.read(engineVersionProvider.future), isNull);

    final signed = await signedInContainer(FakeTix());
    expect(await signed.read(serverVersionProvider.future), 'v1.2.3');
    expect(signed.read(serverAddressProvider), 'https://tix.example');
  });
}
