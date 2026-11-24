// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/platform/dav_profile.dart';

const _text = DavProfileText(
  account: 'tix: Acme',
  displayName: 'tix tasks',
  description: 'Adds your tix tasks to Reminders.',
);

String _build({
  String url = 'https://tix.example.com/dav/',
  String username = 'ana@example.com',
  String password = 'tix_pat_secret',
  String connection = 'c1',
  DavProfileText text = _text,
}) => buildCalDavProfile(
  account: DavAccount(url: url, username: username, password: password),
  connectionId: connection,
  text: text,
  payloadUuid: 'AAAAAAAA-0000-4000-8000-000000000001',
  profileUuid: 'AAAAAAAA-0000-4000-8000-000000000002',
);

/// The value after `<key>[key]</key>` in the first payload that has it.
String _value(String xml, String key) {
  final m = RegExp(
    '<key>$key</key>\\s*(<string>([^<]*)</string>|<integer>(\\d+)</integer>|<(true|false)/>)',
  ).firstMatch(xml);
  if (m == null) fail('no $key in profile');
  return m.group(2) ?? m.group(3) ?? m.group(4)!;
}

void main() {
  group('the profile', () {
    test('is the CalDAV payload Reminders reads, for an https server', () {
      final xml = _build();
      expect(xml, startsWith('<?xml version="1.0" encoding="UTF-8"?>\n'));
      expect(xml, contains('<!DOCTYPE plist PUBLIC'));
      expect(
        xml,
        contains(
          '<key>PayloadType</key>\n      <string>com.apple.caldav.account</string>',
        ),
      );
      expect(_value(xml, 'CalDAVHostName'), 'tix.example.com');
      expect(_value(xml, 'CalDAVPort'), '443');
      expect(_value(xml, 'CalDAVUseSSL'), 'true');
      expect(_value(xml, 'CalDAVPrincipalURL'), 'https://tix.example.com/dav/');
      expect(_value(xml, 'CalDAVUsername'), 'ana@example.com');
      expect(_value(xml, 'CalDAVPassword'), 'tix_pat_secret');
      expect(_value(xml, 'CalDAVAccountDescription'), 'tix: Acme');
      expect(_value(xml, 'PayloadRemovalDisallowed'), 'false');
      expect(xml, contains('<string>Configuration</string>'));
      expect(xml, contains('<string>red.tix.mobile.caldav.c1</string>'));
      expect(
        xml,
        contains('<string>red.tix.mobile.caldav.c1.account</string>'),
      );
      expect(xml.trimRight(), endsWith('</plist>'));
    });

    test('keeps a plain http server and its port', () {
      final xml = _build(url: 'http://10.0.0.2:8080/tix/dav/');
      expect(_value(xml, 'CalDAVHostName'), '10.0.0.2');
      expect(_value(xml, 'CalDAVPort'), '8080');
      expect(_value(xml, 'CalDAVUseSSL'), 'false');
      expect(
        _value(xml, 'CalDAVPrincipalURL'),
        'http://10.0.0.2:8080/tix/dav/',
      );
    });

    test('escapes what would break the XML', () {
      final xml = _build(
        username: 'a&b@example.com',
        password: '<p>"q"\'&',
        text: const DavProfileText(
          account: 'tix: R&D <ops>',
          displayName: 'tix',
          description: 'x',
        ),
      );
      expect(xml, contains('<string>a&amp;b@example.com</string>'));
      expect(
        xml,
        contains('<string>&lt;p&gt;&quot;q&quot;&apos;&amp;</string>'),
      );
      expect(xml, contains('<string>tix: R&amp;D &lt;ops&gt;</string>'));
      expect(xml, isNot(contains('<p>')));
    });

    test('is identified per connection, so setting up again replaces it', () {
      final first = _build();
      final again = _build(password: 'another');
      expect(
        _value(first, 'PayloadIdentifier'),
        _value(again, 'PayloadIdentifier'),
      );
      expect(davProfileIdentifier('c1'), isNot(davProfileIdentifier('c2')));
      expect(davProfileIdentifier('a b/c'), 'red.tix.mobile.caldav.a-b-c');
    });
  });

  test('UUIDs are version 4, upper case and fresh', () {
    final r = Random(1);
    final a = randomUuid(r);
    final b = randomUuid(r);
    final shape = RegExp(
      r'^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$',
    );
    expect(a, matches(shape));
    expect(b, matches(shape));
    expect(a, isNot(b));
  });

  group('the DAVx5 address', () {
    test('is caldavs for https and caldav for http, port and path kept', () {
      expect(
        davx5Address('https://tix.example.com/dav/'),
        'caldavs://tix.example.com/dav/',
      );
      expect(
        davx5Address('http://10.0.0.2:8080/dav/'),
        'caldav://10.0.0.2:8080/dav/',
      );
      expect(
        davx5Address('https://tix.example.com'),
        'caldavs://tix.example.com/',
      );
    });

    test('never carries user info', () {
      final a = davx5Address('https://ana:secret@tix.example.com/dav/');
      expect(a, 'caldavs://tix.example.com/dav/');
      expect(a, isNot(contains('secret')));
      expect(a, isNot(contains('@')));
    });
  });

  test('an account never prints its password', () {
    const a = DavAccount(
      url: 'https://tix.example/dav/',
      username: 'ana',
      password: 'tix_pat_secret',
    );
    expect('$a', isNot(contains('tix_pat_secret')));
  });
}
