// SPDX-License-Identifier: AGPL-3.0-or-later

@TestOn('linux')
library;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/platform/deep_links.dart';
import 'package:tix_mobile/src/core/platform/sso_browser.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('tix/links-sso-test');
  final url = Uri.parse('https://tix.example/login/sso/acme?app_state=s');
  late DeepLinkIntake intake;
  late List<Uri> launched;

  setUp(() {
    intake = DeepLinkIntake(channel);
    addTearDown(intake.dispose);
    launched = [];
  });

  PlatformSsoBrowser browser({bool opens = true}) => PlatformSsoBrowser(
    intake,
    launch: (u) async {
      launched.add(u);
      return opens;
    },
  );

  test('the desktop opens the browser and hears the redirect', () async {
    final b = browser();
    expect(b.supported, isTrue);
    final answer = b.authenticate(url);
    await pumpEventQueue();
    expect(launched, [url]);
    intake.deliver(Uri.parse('tix://inbox'));
    final redirect = Uri.parse('red.tix.mobile:/sso?code=c&state=s');
    intake.deliver(redirect);
    expect(await answer, redirect);
  });

  test('cancel gives up the sign-in', () async {
    final b = browser();
    final answer = b.authenticate(url);
    await pumpEventQueue();
    await b.cancel();
    expect(await answer, isNull);
    intake.deliver(Uri.parse('red.tix.mobile:/sso?code=late'));
  });

  test('a browser that will not open fails the sign-in', () async {
    await expectLater(
      browser(opens: false).authenticate(url),
      throwsA(
        isA<TixException>().having(
          (e) => e.kind,
          'kind',
          TixErrorKind.ssoFailed,
        ),
      ),
    );
  });
}
