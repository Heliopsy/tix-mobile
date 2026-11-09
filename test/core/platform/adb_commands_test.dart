// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/platform/adb_commands.dart';

/// Records what each command asked for.
class FakeActions implements AdbActions {
  final calls = <String>[];
  Exception? fail;

  Future<String> _did(String call) async {
    final f = fail;
    if (f != null) throw f;
    calls.add(call);
    return 'did $call';
  }

  @override
  Future<String> snapshot(AdbSection section) =>
      _did('snapshot ${section.name}');

  @override
  Future<String> reconnect() => _did('reconnect');

  @override
  Future<String> syncNow() => _did('sync-now');

  @override
  Future<String> switchTo(String name) => _did('switch $name');

  @override
  Future<String> quickAdd(String line, {String? project}) =>
      _did('quick-add $line in ${project ?? '-'}');

  @override
  Future<String> engineStop() => _did('engine-stop');

  @override
  Future<String> engineStart() => _did('engine-start');

  @override
  Future<String> clearCache() => _did('clear-cache');

  @override
  Future<String> theme(String name) => _did('theme $name');

  @override
  Future<String> locale(String code) => _did('locale $code');
}

void main() {
  group('parseAdbCommand', () {
    test('no command is help', () {
      expect(parseAdbCommand(null, const {}).name, 'help');
      expect(parseAdbCommand('  ', const {}).name, 'help');
    });

    test('the argument comes from its extra', () {
      final c = parseAdbCommand('switch', const {'context': ' c1.acme '});
      expect(c.name, 'switch');
      expect(c.arg, 'c1.acme');
    });

    test('or from what follows the name', () {
      final c = parseAdbCommand('Theme  dark', const {});
      expect(c.name, 'theme');
      expect(c.arg, 'dark');
      expect(
        parseAdbCommand('quick-add Renew the cert !high', const {}).arg,
        'Renew the cert !high',
      );
    });

    test('the extra wins over the rest of the command', () {
      expect(parseAdbCommand('locale de', const {'value': 'fr'}).arg, 'fr');
    });

    test('dump takes an optional section', () {
      expect(parseAdbCommand('dump', const {}).arg, '');
      expect(parseAdbCommand('dump outbox', const {}).arg, 'outbox');
    });

    test('a command missing its argument says how to call it', () {
      expect(
        () => parseAdbCommand('switch', const {}),
        throwsA(
          isA<AdbError>().having(
            (e) => e.message,
            'message',
            contains('switch --es context'),
          ),
        ),
      );
      expect(
        () => parseAdbCommand('open', const {'link': '  '}),
        throwsA(isA<AdbError>()),
      );
    });

    test('an unknown command points at help', () {
      expect(
        () => parseAdbCommand('format-disk', const {}),
        throwsA(
          isA<AdbError>().having(
            (e) => e.message,
            'message',
            'unknown command "format-disk": try help',
          ),
        ),
      );
    });

    for (final key in ['token', 'Password', 'cookie', 'session', 'secret']) {
      test('an extra called $key is refused', () {
        expect(
          () => parseAdbCommand('switch', {'context': 'c1', key: 'x'}),
          throwsA(
            isA<AdbError>().having(
              (e) => e.message,
              'message',
              contains('never take credentials'),
            ),
          ),
        );
      });
    }
  });

  group('adbSectionNamed', () {
    test('names each section, empty for all', () {
      expect(adbSectionNamed(''), AdbSection.all);
      for (final s in AdbSection.values) {
        expect(adbSectionNamed(s.name.toUpperCase()), s);
      }
      expect(adbSectionNamed('secrets'), isNull);
    });
  });

  group('gating', () {
    final help = parseAdbCommand('help', const {});
    final dump = parseAdbCommand('dump', const {});
    final theme = parseAdbCommand('theme dark', const {});

    test('a debug build runs everything', () {
      expect(adbAllowed(theme, debugBuild: true, enabled: false), isTrue);
    });

    test('a release build runs commands only with the setting on', () {
      expect(adbAllowed(theme, debugBuild: false, enabled: false), isFalse);
      expect(adbAllowed(theme, debugBuild: false, enabled: true), isTrue);
    });

    test('help and dump only read, so they always run', () {
      for (final c in [help, dump]) {
        expect(adbAllowed(c, debugBuild: false, enabled: false), isTrue);
      }
    });

    test(
      'a release build with the setting off says how to turn it on',
      () async {
        final actions = FakeActions();
        final reply = await runAdbCommand(
          'theme',
          const {'value': 'dark'},
          actions: actions,
          debugBuild: false,
          enabled: false,
        );
        expect(reply.ok, isFalse);
        expect(
          reply.text,
          'disabled: enable Settings > Advanced > Allow control over ADB',
        );
        expect(actions.calls, isEmpty);
      },
    );

    test('a release build with the setting on runs it', () async {
      final actions = FakeActions();
      final reply = await runAdbCommand(
        'theme',
        const {'value': 'dark'},
        actions: actions,
        debugBuild: false,
        enabled: true,
      );
      expect(reply.ok, isTrue);
      expect(actions.calls, ['theme dark']);
    });
  });

  group('runAdbCommand', () {
    late FakeActions actions;

    setUp(() => actions = FakeActions());

    Future<AdbReply> run(String cmd, [Map<String, String> extras = const {}]) =>
        runAdbCommand(
          cmd,
          extras,
          actions: actions,
          debugBuild: true,
          enabled: false,
        );

    Future<AdbReply> headless(String cmd) => runAdbCommand(
      cmd,
      const {},
      actions: actions,
      debugBuild: true,
      enabled: false,
      headless: true,
    );

    final dispatch = {
      'reconnect': 'reconnect',
      'sync-now': 'sync-now',
      'switch work': 'switch work',
      'quick-add Renew cert': 'quick-add Renew cert in -',
      'engine-stop': 'engine-stop',
      'engine-start': 'engine-start',
      'clear-cache': 'clear-cache',
      'theme OLED': 'theme oled',
      'locale bg': 'locale bg',
      'locale system': 'locale system',
      'dump': 'snapshot all',
      'dump engine': 'snapshot engine',
    };
    for (final MapEntry(key: cmd, value: call) in dispatch.entries) {
      test('$cmd runs $call', () async {
        final reply = await run(cmd);
        expect(reply.ok, isTrue, reason: reply.text);
        expect(actions.calls, [call]);
        expect(reply.text, 'did $call');
      });
    }

    test('quick-add passes the project', () async {
      await run('quick-add', const {'line': 'Renew', 'project': 'OPS'});
      expect(actions.calls, ['quick-add Renew in OPS']);
    });

    test('help lists every command', () async {
      final reply = await run('help');
      for (final c in adbCommands) {
        expect(reply.text, contains(c.usage));
      }
      expect(actions.calls, isEmpty);
    });

    test('a bad theme, language or section is refused', () async {
      for (final cmd in ['theme sepia', 'locale es', 'dump secrets']) {
        final reply = await run(cmd);
        expect(reply.ok, isFalse, reason: cmd);
      }
      expect(actions.calls, isEmpty);
    });

    test('open answers with the link for the platform to open', () async {
      final reply = await run('open', const {'link': 'tix://projects/OPS'});
      expect(reply.ok, isTrue);
      expect(reply.launch, 'tix://projects/OPS');
      expect(reply.toMap()['launch'], 'tix://projects/OPS');
    });

    test(
      'open still sends an unknown tix link, which the app explains',
      () async {
        final reply = await run('open', const {'link': 'tix://nowhere'});
        expect(reply.launch, 'tix://nowhere');
        expect(reply.text, contains('not a link tix knows'));
      },
    );

    test('open refuses anything but a tix link', () async {
      for (final link in ['https://evil.example', 'tixwidget://drain']) {
        final reply = await run('open', {'link': link});
        expect(reply.ok, isFalse, reason: link);
        expect(reply.launch, isNull);
      }
    });

    test('a headless engine hands commands that need the app back', () async {
      for (final cmd in ['switch work', 'quick-add x', 'sync-now']) {
        final reply = await headless(cmd);
        expect(reply.needsApp, isTrue, reason: cmd);
        expect(reply.toMap()['needsApp'], isTrue);
      }
      for (final cmd in ['theme dark', 'dump', 'help', 'open tix://inbox']) {
        final reply = await headless(cmd);
        expect(reply.needsApp, isFalse, reason: cmd);
      }
      expect(actions.calls, ['theme dark', 'snapshot all']);
    });

    test('a failure is printed without its secrets', () async {
      actions.fail = const TixException(
        TixErrorKind.network,
        message: 'GET https://tix.example/api?token=abcdef123 failed',
      );
      final reply = await run('reconnect');
      expect(reply.ok, isFalse);
      expect(reply.text, startsWith('failed: network'));
      expect(reply.text, isNot(contains('abcdef123')));
    });

    test('an action refusing says why', () async {
      actions.fail = const AdbError('no context is active: sign in first');
      final reply = await run('sync-now');
      expect(reply.ok, isFalse);
      expect(reply.text, 'no context is active: sign in first');
    });

    test('a reply carrying a credential is redacted', () async {
      final reply = await runAdbCommand(
        'switch',
        const {'context': 'tok-0123456789'},
        actions: actions,
        debugBuild: true,
        enabled: false,
        secrets: ['tok-0123456789'],
      );
      expect(reply.text, isNot(contains('tok-0123456789')));
    });
  });
}
