// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/platform/deep_links.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TixLink? parse(String link) => parseTixLink(Uri.parse(link));

  group('parseTixLink', () {
    const routes = {
      'tix://inbox': '/inbox',
      'tix://mine': '/mine',
      'tix://tasks': '/tasks',
      'tix://projects': '/projects',
      'tix://projects/OPS': '/projects/OPS',
      'tix://projects/OPS/tasks/OPS-12': '/projects/OPS/tasks/OPS-12',
      'tix://settings': '/settings',
      'tix://about': '/settings/about',
      'tix://activity': '/activity',
      'tix://watch': '/activity',
      'tix://projects/': '/projects',
      'tix:///inbox': '/inbox',
      'TIX://Inbox': '/inbox',
    };
    for (final MapEntry(key: link, value: route) in routes.entries) {
      test('$link goes to $route', () {
        expect(parse(link), TixLink(route: route));
      });
    }

    test('tix://connection opens the connection details over the screen', () {
      final link = parse('tix://connection');
      expect(link, isNotNull);
      expect(link!.route, isNull);
      expect(link.context, isNull);
    });

    test('a context is kept as named, trimmed', () {
      expect(
        parse('tix://projects/OPS?context=Work%20%C2%B7%20Acme'),
        const TixLink(route: '/projects/OPS', context: 'Work · Acme'),
      );
      expect(
        parse('tix://connection?context=c1.acme'),
        const TixLink(context: 'c1.acme'),
      );
      expect(parse('tix://inbox?context=%20'), const TixLink(route: '/inbox'));
    });

    test('other query parameters are ignored', () {
      expect(parse('tix://inbox?x=1'), const TixLink(route: '/inbox'));
    });

    test('tix://tasks with a filter opens that saved filter', () {
      expect(
        parse('tix://tasks?filter=f7&context=s1.acme'),
        const TixLink(route: '/tasks?filter=f7', context: 's1.acme'),
      );
      expect(
        parse('tix://tasks?filter=Due%20soon'),
        const TixLink(route: '/tasks?filter=Due+soon'),
      );
      expect(parse('tix://tasks?filter=%20'), const TixLink(route: '/tasks'));
    });

    test('tix://quick-add opens quick add, in a project when named', () {
      expect(parse('tix://quick-add'), const TixLink(quickAdd: true));
      expect(
        parse('tix://quick-add?project=OPS&context=s1.acme'),
        const TixLink(quickAdd: true, project: 'OPS', context: 's1.acme'),
      );
      expect(parse('tix://quick-add?project=..%2Fx'), isNull);
      expect(parse('tix://quick-add/now'), isNull);
    });

    for (final link in [
      'https://tix.example/inbox',
      'tixwidget://open?route=/inbox',
      'tix://',
      'tix://nowhere',
      'tix://inbox/extra',
      'tix://projects/OPS/tasks',
      'tix://projects/OPS/settings',
      'tix://projects/OPS/tasks/OPS-12/edit',
      'tix://projects/..%2Fmanage',
      'tix://projects/-x',
      'tix://settings/tokens',
    ]) {
      test('$link is not recognised', () {
        expect(parse(link), isNull);
      });
    }
  });

  group('tixLinkTo', () {
    test('builds a link that parses back with its context', () {
      final project = tixLinkTo('projects/OPS', context: 's1.acme');
      expect(project.toString(), 'tix://projects/OPS?context=s1.acme');
      expect(
        parseTixLink(project),
        const TixLink(route: '/projects/OPS', context: 's1.acme'),
      );
      final filter = tixLinkTo(
        'tasks',
        context: 'c1.',
        query: {'filter': 'f 7'},
      );
      expect(
        parseTixLink(filter),
        const TixLink(route: '/tasks?filter=f+7', context: 'c1.'),
      );
    });

    test('leaves the context out when there is none', () {
      expect(tixLinkTo('inbox').toString(), 'tix://inbox');
      expect(tixLinkTo('quick-add', context: '').toString(), 'tix://quick-add');
    });
  });

  group('DeepLinkIntake', () {
    const channel = MethodChannel('tix/links-test');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    String? pending;

    setUp(() {
      pending = null;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method != 'take') return null;
        final p = pending;
        pending = null;
        return p;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    });

    test('start takes the link that launched the app', () async {
      pending = 'tix://inbox';
      final intake = DeepLinkIntake(channel);
      addTearDown(intake.dispose);
      final got = <Uri>[];
      intake.links.listen(got.add);
      await intake.start();
      await pumpEventQueue();
      expect(got, [Uri.parse('tix://inbox')]);
    });

    test('a link opened while running is pulled when told', () async {
      final intake = DeepLinkIntake(channel);
      addTearDown(intake.dispose);
      final got = <Uri>[];
      intake.links.listen(got.add);
      pending = 'tix://projects/OPS';
      await messenger.handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(const MethodCall('opened')),
        (_) {},
      );
      await pumpEventQueue();
      expect(got, [Uri.parse('tix://projects/OPS')]);
    });

    test('a link nobody listens for waits to be taken', () async {
      pending = 'tix://about';
      final intake = DeepLinkIntake(channel);
      addTearDown(intake.dispose);
      await intake.start();
      expect(intake.take(), Uri.parse('tix://about'));
      expect(intake.take(), isNull);
    });

    test('a delivered link reaches a listener', () async {
      final intake = DeepLinkIntake(channel);
      addTearDown(intake.dispose);
      final got = <Uri>[];
      intake.links.listen(got.add);
      intake.deliver(Uri.parse('tix://quick-add'));
      await pumpEventQueue();
      expect(got, [Uri.parse('tix://quick-add')]);
      expect(intake.take(), isNull);
    });

    test('a delivered link nobody listens for waits to be taken', () {
      final intake = DeepLinkIntake(channel);
      addTearDown(intake.dispose);
      intake.deliver(Uri.parse('tix://inbox'));
      expect(intake.take(), Uri.parse('tix://inbox'));
    });
  });
}
