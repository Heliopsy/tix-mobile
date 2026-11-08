// SPDX-License-Identifier: AGPL-3.0-or-later

// How much of the tix API the app covers, per wave.
//
//   dart run tool/parity.dart
//
// Reads every operationId in api/tix-openapi.yaml, the bindings in
// lib/src/core/capability/registry.dart and the exempt and pending lists in
// lib/src/core/capability/exemptions.yaml. test/core/capability/
// operations_test.dart enforces the same classification.

import 'dart:io';

import 'package:tix_mobile/src/core/capability/registry.dart';
import 'package:yaml/yaml.dart';

/// The vendored spec.
const specPath = 'api/tix-openapi.yaml';

/// The exempt and pending lists.
const exemptionsPath = 'lib/src/core/capability/exemptions.yaml';

/// Every operation, sorted into what the app does with it.
class Parity {
  /// Classifies the operations of [spec] against [bound] and [exemptions].
  factory Parity(String spec, String exemptions, Map<String, Binding> bound) {
    final doc = loadYaml(spec) as YamlMap;
    final ops = <String>{};
    for (final item in (doc['paths'] as YamlMap).values) {
      for (final MapEntry(:key, :value) in (item as YamlMap).entries) {
        if (const {'get', 'post', 'put', 'patch', 'delete'}.contains(key)) {
          ops.add((value as YamlMap)['operationId'] as String);
        }
      }
    }
    final ex = loadYaml(exemptions) as YamlMap;
    final exempt = <String, String>{
      for (final MapEntry(:key, :value) in (ex['exempt'] as YamlMap).entries)
        key as String: ((value as YamlMap)['reason'] as String?) ?? '',
    };
    final pending = <String, int>{};
    final duplicates = <String>[];
    final badWaves = <String>[];
    for (final MapEntry(:key, :value) in (ex['pending'] as YamlMap).entries) {
      final m = RegExp(r'^wave([123])$').firstMatch(key as String);
      if (m == null) {
        badWaves.add(key);
        continue;
      }
      for (final op in (value as YamlList? ?? YamlList()).cast<String>()) {
        if (pending.containsKey(op)) duplicates.add(op);
        pending[op] = int.parse(m[1]!);
      }
    }
    return Parity._(ops, bound, exempt, pending, duplicates, badWaves);
  }

  Parity._(
    this.operations,
    this.bound,
    this.exempt,
    this.pending,
    this.duplicates,
    this.badWaves,
  );

  /// Every operationId in the spec.
  final Set<String> operations;

  /// The bound operations.
  final Map<String, Binding> bound;

  /// Exempt operations and why.
  final Map<String, String> exempt;

  /// Pending operations and their wave.
  final Map<String, int> pending;

  /// Operations listed twice under pending.
  final List<String> duplicates;

  /// Keys under pending that are not wave1, wave2 or wave3.
  final List<String> badWaves;

  /// Operations in the spec that are neither bound, exempt nor pending.
  List<String> get unclassified => [
    for (final op in operations)
      if (!bound.containsKey(op) &&
          !exempt.containsKey(op) &&
          !pending.containsKey(op))
        op,
  ]..sort();

  /// Operations classified more than once.
  List<String> get conflicting => [
    for (final op in {...bound.keys, ...exempt.keys, ...pending.keys})
      if ([
            bound.containsKey(op),
            exempt.containsKey(op),
            pending.containsKey(op),
          ].where((b) => b).length >
          1)
        op,
    ...duplicates,
  ]..sort();

  /// Classified operations the spec no longer has.
  List<String> get stale => [
    for (final op in {...bound.keys, ...exempt.keys, ...pending.keys})
      if (!operations.contains(op)) op,
  ]..sort();

  /// Exemptions that give no reason.
  List<String> get unexplained => [
    for (final MapEntry(:key, :value) in exempt.entries)
      if (value.trim().isEmpty) key,
  ]..sort();

  /// The coverage table, one line per wave.
  String report() {
    final lines = <String>['wave   bound  pending  coverage'];
    for (final w in [0, 1, 2, 3]) {
      final done = bound.values.where((b) => b.wave == w).length;
      final left = pending.values.where((p) => p == w).length;
      final total = done + left;
      final pct = total == 0 ? 100.0 : 100 * done / total;
      lines.add(
        '${'$w'.padRight(6)} ${'$done'.padLeft(5)}  ${'$left'.padLeft(7)}  '
        '${pct.toStringAsFixed(0).padLeft(7)}%',
      );
    }
    final offered = operations.length - exempt.length;
    final pct = 100 * bound.length / offered;
    lines
      ..add('')
      ..add(
        '${operations.length} operations: ${bound.length} bound, '
        '${pending.length} pending, ${exempt.length} exempt; '
        '${pct.toStringAsFixed(1)}% of the $offered the app should offer',
      );
    return lines.join('\n');
  }
}

void main() {
  final parity = Parity(
    File(specPath).readAsStringSync(),
    File(exemptionsPath).readAsStringSync(),
    bindings,
  );
  stdout.writeln(parity.report());
  final problems = [
    ...parity.unclassified.map((o) => 'unclassified: $o'),
    ...parity.conflicting.map((o) => 'classified twice: $o'),
    ...parity.stale.map((o) => 'not in the spec: $o'),
    ...parity.unexplained.map((o) => 'exempt without a reason: $o'),
    ...parity.badWaves.map((w) => 'unknown wave: $w'),
  ];
  if (problems.isNotEmpty) {
    stderr.writeln(problems.join('\n'));
    exitCode = 1;
  }
}
