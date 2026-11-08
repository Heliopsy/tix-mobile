// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/data/models/integrations.dart';
import 'package:tix_mobile/src/features/maintenance/application/maintenance.dart';

/// Whole days in a Go duration such as `720h0m0s`, or null when it is not
/// one.
int? daysOf(String? duration) {
  final m = RegExp(r'^(\d+)h').firstMatch(duration ?? '');
  if (m == null) return null;
  final hours = int.parse(m[1]!);
  return hours % 24 == 0 ? hours ~/ 24 : null;
}

/// How long the tenant keeps events, audit entries and webhook deliveries,
/// and pruning what is past that now.
class RetentionScreen extends ConsumerWidget {
  /// Creates the screen.
  const RetentionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return TixPage(
      title: l10n.retentionTitle,
      subtitle: l10n.retentionSubtitle,
      body: AsyncBody(
        value: ref.watch(retentionProvider),
        onRetry: () => ref.invalidate(retentionProvider),
        data: (policy) => ListView(
          padding: const EdgeInsets.only(bottom: TixSpace.s6),
          children: [
            _RetentionForm(key: ValueKey(policy), policy: policy),
            const _PruneSection(),
          ],
        ),
      ),
    );
  }
}

class _RetentionForm extends ConsumerStatefulWidget {
  const _RetentionForm({required this.policy, super.key});

  final RetentionPolicy policy;

  @override
  ConsumerState<_RetentionForm> createState() => _RetentionFormState();
}

class _RetentionFormState extends ConsumerState<_RetentionForm> {
  late final _fields = {
    'events': TextEditingController(text: _days(widget.policy.events)),
    'audit': TextEditingController(text: _days(widget.policy.auditEntries)),
    'deliveries': TextEditingController(
      text: _days(widget.policy.webhookDeliveries),
    ),
  };
  bool _busy = false;
  String? _error;

  static String _days(String? d) => daysOf(d)?.toString() ?? d ?? '';

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? _duration(String key) {
    final text = _fields[key]!.text.trim();
    if (text.isEmpty) return null;
    final days = int.tryParse(text);
    return days == null ? text : '${days * 24}h';
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final l10n = context.l10n;
    try {
      await ref
          .read(retentionProvider.notifier)
          .save(
            events: _duration('events'),
            auditEntries: _duration('audit'),
            webhookDeliveries: _duration('deliveries'),
          );
      if (mounted) showTixToast(context, l10n.retentionSaved);
    } on TixException catch (e) {
      if (mounted) setState(() => _error = errorMessage(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget field(String key, String label, String help) => Padding(
      padding: const EdgeInsets.fromLTRB(
        TixSpace.s4,
        TixSpace.s3,
        TixSpace.s4,
        0,
      ),
      child: TixTextField(
        fieldKey: Key('retention.$key'),
        label: label,
        help: help,
        controller: _fields[key],
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
    return TixSection(
      title: l10n.retentionWindows,
      subtitle: l10n.retentionWindowsHelp,
      children: [
        field('events', l10n.retentionEvents, l10n.retentionEventsHelp),
        field('audit', l10n.retentionAudit, l10n.retentionAuditHelp),
        field(
          'deliveries',
          l10n.retentionDeliveries,
          l10n.retentionDeliveriesHelp,
        ),
        Padding(
          padding: const EdgeInsets.all(TixSpace.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null) ...[
                Text(
                  _error!,
                  key: const Key('retention.error'),
                  style: TextStyle(color: context.tix.danger),
                ),
                const SizedBox(height: TixSpace.s2),
              ],
              TixButton.primary(
                key: const Key('retention.save'),
                label: l10n.retentionSave,
                busy: _busy,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PruneSection extends ConsumerStatefulWidget {
  const _PruneSection();

  @override
  ConsumerState<_PruneSection> createState() => _PruneSectionState();
}

class _PruneSectionState extends ConsumerState<_PruneSection> {
  PruneResult? _result;
  bool _busy = false;

  Future<void> _run({required bool dryRun}) async {
    final l10n = context.l10n;
    if (!dryRun) {
      final ok = await confirmDestructive(
        context,
        title: l10n.retentionPruneTitle,
        body: l10n.retentionPruneBody,
        action: l10n.retentionPrune,
      );
      if (!ok || !mounted) return;
    }
    setState(() => _busy = true);
    try {
      final result = await ref
          .read(retentionProvider.notifier)
          .prune(dryRun: dryRun);
      if (!mounted) return;
      setState(() => _result = result);
      if (!dryRun) showTixToast(context, l10n.retentionPruned);
    } on TixException catch (e) {
      if (mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final result = _result;
    return TixSection(
      title: l10n.retentionPruneSection,
      subtitle: l10n.retentionPruneHelp,
      danger: true,
      children: [
        Padding(
          padding: const EdgeInsets.all(TixSpace.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (result != null) ...[
                Text(
                  key: const Key('retention.result'),
                  result.dryRun
                      ? l10n.retentionWouldPrune(
                          result.events,
                          result.auditEntries,
                          result.webhookDeliveries,
                        )
                      : l10n.retentionDidPrune(
                          result.events,
                          result.auditEntries,
                          result.webhookDeliveries,
                        ),
                ),
                if (result.retainedForSubscribers > 0)
                  Text(
                    l10n.retentionKeptForSubscribers(
                      result.retainedForSubscribers,
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: TixSpace.s3),
              ],
              Wrap(
                spacing: TixSpace.s2,
                runSpacing: TixSpace.s2,
                children: [
                  TixButton(
                    key: const Key('retention.preview'),
                    label: l10n.retentionPreview,
                    icon: Icons.visibility_outlined,
                    onPressed: _busy ? null : () => _run(dryRun: true),
                  ),
                  TixButton.danger(
                    key: const Key('retention.prune'),
                    label: l10n.retentionPrune,
                    icon: Icons.delete_sweep_outlined,
                    busy: _busy,
                    onPressed: () => _run(dryRun: false),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
