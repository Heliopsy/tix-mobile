// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/data/models/integrations.dart';
import 'package:tix_mobile/src/features/maintenance/application/maintenance.dart';

/// The tenant's housekeeping: how long done and cancelled tasks stay before
/// they move to the trash, how long the trash keeps them, and running it.
class HousekeepingScreen extends ConsumerWidget {
  /// Creates the screen.
  const HousekeepingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return TixPage(
      title: l10n.housekeepingTitle,
      subtitle: l10n.housekeepingSubtitle,
      body: AsyncBody(
        value: ref.watch(housekeepingProvider),
        onRetry: () => ref.invalidate(housekeepingProvider),
        data: (view) => ListView(
          padding: const EdgeInsets.only(bottom: TixSpace.s6),
          children: [
            if (view.paused)
              Container(
                key: const Key('housekeeping.paused'),
                margin: const EdgeInsets.fromLTRB(
                  TixSpace.s4,
                  TixSpace.s4,
                  TixSpace.s4,
                  0,
                ),
                padding: const EdgeInsets.all(TixSpace.s3),
                decoration: BoxDecoration(
                  color: context.tix.warnSoft,
                  borderRadius: BorderRadius.circular(TixRadius.md),
                ),
                child: Text(l10n.housekeepingPaused),
              ),
            _RulesForm(key: ValueKey(view), view: view),
            const _RunSection(),
          ],
        ),
      ),
    );
  }
}

class _RulesForm extends ConsumerStatefulWidget {
  const _RulesForm({required this.view, super.key});

  final HousekeepingView view;

  @override
  ConsumerState<_RulesForm> createState() => _RulesFormState();
}

class _RulesFormState extends ConsumerState<_RulesForm> {
  late final _fields = {
    'done': TextEditingController(text: _rule(widget.view.tenant?.done)),
    'cancelled': TextEditingController(
      text: _rule(widget.view.tenant?.cancelled),
    ),
    'trash': TextEditingController(text: _rule(widget.view.tenant?.trash)),
  };
  bool _busy = false;
  String? _error;

  static String _rule(int? days) => days == null || days == 0 ? 'off' : '$days';

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? _value(String key) {
    final text = _fields[key]!.text.trim();
    return text.isEmpty ? 'off' : text;
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final l10n = context.l10n;
    try {
      await ref
          .read(housekeepingProvider.notifier)
          .save(
            done: _value('done'),
            cancelled: _value('cancelled'),
            trash: _value('trash'),
          );
      if (mounted) showTixToast(context, l10n.housekeepingSaved);
    } on TixException catch (e) {
      if (mounted) setState(() => _error = errorMessage(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pending = widget.view.pending;
    Widget field(String key, String label, String help, int count) => Padding(
      padding: const EdgeInsets.fromLTRB(
        TixSpace.s4,
        TixSpace.s3,
        TixSpace.s4,
        0,
      ),
      child: TixTextField(
        fieldKey: Key('housekeeping.$key'),
        label: label,
        help: '$help ${l10n.housekeepingPending(count)}',
        controller: _fields[key],
      ),
    );
    return TixSection(
      title: l10n.housekeepingRules,
      subtitle: l10n.housekeepingRulesHelp,
      children: [
        field(
          'done',
          l10n.housekeepingDone,
          l10n.housekeepingDoneHelp,
          pending?.done ?? 0,
        ),
        field(
          'cancelled',
          l10n.housekeepingCancelled,
          l10n.housekeepingCancelledHelp,
          pending?.cancelled ?? 0,
        ),
        field(
          'trash',
          l10n.housekeepingTrash,
          l10n.housekeepingTrashHelp,
          pending?.trash ?? 0,
        ),
        Padding(
          padding: const EdgeInsets.all(TixSpace.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null) ...[
                Text(
                  _error!,
                  key: const Key('housekeeping.error'),
                  style: TextStyle(color: context.tix.danger),
                ),
                const SizedBox(height: TixSpace.s2),
              ],
              TixButton.primary(
                key: const Key('housekeeping.save'),
                label: l10n.housekeepingSave,
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

class _RunSection extends ConsumerStatefulWidget {
  const _RunSection();

  @override
  ConsumerState<_RunSection> createState() => _RunSectionState();
}

class _RunSectionState extends ConsumerState<_RunSection> {
  HousekeepingResult? _result;
  bool _busy = false;

  Future<void> _run({required bool dryRun}) async {
    final l10n = context.l10n;
    if (!dryRun) {
      final ok = await confirmDestructive(
        context,
        title: l10n.housekeepingRunTitle,
        body: l10n.housekeepingRunBody,
        action: l10n.housekeepingRun,
      );
      if (!ok || !mounted) return;
    }
    setState(() => _busy = true);
    try {
      final result = await ref
          .read(housekeepingProvider.notifier)
          .run(dryRun: dryRun);
      if (mounted) setState(() => _result = result);
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
      title: l10n.housekeepingRunSection,
      subtitle: l10n.housekeepingRunHelp,
      danger: true,
      children: [
        Padding(
          padding: const EdgeInsets.all(TixSpace.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (result != null) ...[
                Text(
                  key: const Key('housekeeping.result'),
                  result.paused
                      ? l10n.housekeepingPaused
                      : result.dryRun
                      ? l10n.housekeepingWould(
                          result.done,
                          result.cancelled,
                          result.trash,
                        )
                      : l10n.housekeepingDid(
                          result.done,
                          result.cancelled,
                          result.trash,
                        ),
                ),
                const SizedBox(height: TixSpace.s3),
              ],
              Wrap(
                spacing: TixSpace.s2,
                runSpacing: TixSpace.s2,
                children: [
                  TixButton(
                    key: const Key('housekeeping.preview'),
                    label: l10n.housekeepingPreview,
                    icon: Icons.visibility_outlined,
                    onPressed: _busy ? null : () => _run(dryRun: true),
                  ),
                  TixButton.danger(
                    key: const Key('housekeeping.run'),
                    label: l10n.housekeepingRun,
                    icon: Icons.cleaning_services_outlined,
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
