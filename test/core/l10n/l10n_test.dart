// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

void main() {
  late AppLocalizations en;
  late AppLocalizations bg;

  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
    bg = await AppLocalizations.delegate.load(const Locale('bg'));
  });

  String msg(TixErrorKind kind, [String message = '']) =>
      errorMessage(en, TixException(kind, message: message));

  test('every kind has its own message', () {
    final seen = <String>{};
    for (final kind in TixErrorKind.values) {
      final text = msg(kind, 'detail');
      expect(text, isNotEmpty, reason: kind.name);
      seen.add(text);
    }
    expect(
      seen.length,
      greaterThanOrEqualTo(12),
      reason: 'kinds collapsed into too few messages: $seen',
    );
  });

  test("the server's message is shown where it explains the refusal", () {
    expect(
      msg(TixErrorKind.invalid, 'unknown project'),
      contains('unknown project'),
    );
    expect(
      msg(TixErrorKind.preconditionFailed, 'trash is off'),
      contains('trash is off'),
    );
    expect(msg(TixErrorKind.notFound, 'task "x-1"'), contains('task "x-1"'));
    expect(msg(TixErrorKind.invalid), en.errorUnknown);
    expect(msg(TixErrorKind.notFound), en.errorNotFound);
  });

  test(
    'a server failure names its request id so the log line can be found',
    () {
      expect(
        errorMessage(
          en,
          const TixException(TixErrorKind.internal, requestId: 'r-42'),
        ),
        '${en.errorServer} Request r-42.',
      );
      expect(msg(TixErrorKind.internal), en.errorServer);
      expect(msg(TixErrorKind.unknown, 'new thing'), contains('new thing'));
    },
  );

  test('a token refusal does not echo the server text', () {
    expect(
      msg(TixErrorKind.unauthenticated, 'secret'),
      en.errorUnauthenticated,
    );
  });

  test('anything that is not a TixException is unknown', () {
    expect(errorMessage(en, StateError('x')), en.errorUnknown);
  });

  test('Bulgarian is translated', () {
    expect(
      errorMessage(bg, const TixException(TixErrorKind.network)),
      isNot(en.errorNetwork),
    );
    expect(bg.projectsTitle, 'Проекти');
    expect(bg.priorityLabel('1'), 'Най-висок');
  });
}
