// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/l10n/via_label.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart' show Via;

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final bg = lookupAppLocalizations(const Locale('bg'));

  test('the channel names the token or the job as the web does', () {
    for (final (via, want) in [
      (null, null),
      (const Via(), null),
      (const Via(kind: 'api', tokenName: 'ci-runner'), 'via token ci-runner'),
      (const Via(kind: 'api'), 'via API'),
      (const Via(kind: 'mcp', tokenName: 'claude'), 'via MCP (token claude)'),
      (
        const Via(kind: 'cli-remote', tokenName: 'laptop'),
        'via CLI (token laptop)',
      ),
      (
        const Via(kind: 'sync', origin: 'api', tokenName: 'ci-runner'),
        'via sync (token ci-runner)',
      ),
      (
        const Via(kind: 'system', job: 'lease-sweep'),
        'via system (lease-sweep)',
      ),
      (const Via(kind: 'cli-local'), 'via CLI'),
      (const Via(kind: 'unknown'), 'via an unknown channel'),
    ]) {
      expect(viaLabel(en, via), want, reason: '$via');
    }
  });

  test('Bulgarian names the token too', () {
    expect(
      viaLabel(bg, const Via(kind: 'api', tokenName: 'ci-runner')),
      'с токен ci-runner',
    );
    expect(
      viaLabel(bg, const Via(kind: 'mcp', tokenName: 'claude')),
      'през MCP (токен claude)',
    );
  });
}
