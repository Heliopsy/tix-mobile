// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/features/settings/application/time_prefs.dart';

/// A date format's name, as the settings list it.
String timeFormatLabel(AppLocalizations l10n, String format) =>
    switch (format) {
      'iso' => l10n.timeFormatIso,
      'rfc3339' => l10n.timeFormatRfc3339,
      'short' => l10n.timeFormatShort,
      'long' => l10n.timeFormatLong,
      'dotted' => l10n.timeFormatDotted,
      'dayfirst' => l10n.timeFormatDayFirst,
      'us' => l10n.timeFormatUs,
      'relative' => l10n.timeFormatRelative,
      _ => format,
    };

/// Where a date setting in force came from.
String timeSourceLabel(AppLocalizations l10n, String source) =>
    switch (source) {
      'user' => l10n.timeSourceUser,
      'tenant' => l10n.timeSourceTenant,
      _ => l10n.timeSourceGlobal,
    };

/// The caller's date format and timezone, which tix keeps with their
/// account so the browser, the terminal and this app agree.
class TimeSettingsScreen extends ConsumerWidget {
  /// Creates the screen.
  const TimeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).value;
    return TixPage(
      title: l10n.timeTitle,
      subtitle: session?.instance.name,
      body: AsyncBody(
        value: ref.watch(timePrefsStateProvider),
        onRetry: () => ref.invalidate(timePrefsStateProvider),
        data: (settings) => ListView(
          padding: const EdgeInsets.only(bottom: TixSpace.s6),
          children: [
            if (!settings.personal)
              Padding(
                key: const Key('time.automated'),
                padding: const EdgeInsets.all(TixSpace.s4),
                child: Text(l10n.timeAutomated),
              ),
            _FormatSection(settings: settings),
            _ZoneSection(settings: settings),
          ],
        ),
      ),
    );
  }
}

Future<void> _save(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
    if (context.mounted) showTixToast(context, context.l10n.timeSaved);
  } on Object catch (e) {
    if (context.mounted) {
      showTixToast(
        context,
        errorMessage(context.l10n, e),
        tone: TixTone.danger,
      );
    }
  }
}

class _FormatSection extends ConsumerWidget {
  const _FormatSection({required this.settings});

  final TimeSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final effective = settings.effective?.timeFormat ?? '';
    final inherited = settings.tenant?.timeFormat.isNotEmpty ?? false
        ? settings.tenant!.timeFormat
        : settings.global?.timeFormat ?? '';
    final own = settings.user?.timeFormat ?? '';
    final notifier = ref.read(timePrefsStateProvider.notifier);
    return TixSection(
      title: l10n.timeFormatTitle,
      subtitle: l10n.timeInForce(
        timeFormatLabel(l10n, effective),
        timeSourceLabel(l10n, settings.formatSource),
      ),
      info: l10n.timeFormatInfo,
      children: [
        Padding(
          padding: const EdgeInsets.all(TixSpace.s3),
          child: TixChoices<String>(
            key: const Key('time.format'),
            choices: [
              TixChoice(
                '',
                inherited.isEmpty
                    ? l10n.timeInherit
                    : l10n.timeInheritValue(timeFormatLabel(l10n, inherited)),
              ),
              for (final f in timeFormats)
                TixChoice(f, timeFormatLabel(l10n, f)),
            ],
            selected: own,
            onSelected: settings.personal
                ? (f) => _save(context, () => notifier.setFormat(f))
                : (_) {},
          ),
        ),
      ],
    );
  }
}

class _ZoneSection extends ConsumerStatefulWidget {
  const _ZoneSection({required this.settings});

  final TimeSettings settings;

  @override
  ConsumerState<_ZoneSection> createState() => _ZoneSectionState();
}

class _ZoneSectionState extends ConsumerState<_ZoneSection> {
  late final _zone = TextEditingController(
    text: widget.settings.user?.timezone ?? '',
  );

  @override
  void didUpdateWidget(_ZoneSection old) {
    super.didUpdateWidget(old);
    final own = widget.settings.user?.timezone ?? '';
    if (own != (old.settings.user?.timezone ?? '')) _zone.text = own;
  }

  @override
  void dispose() {
    _zone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = widget.settings;
    final effective = settings.effective?.timezone ?? '';
    final notifier = ref.read(timePrefsStateProvider.notifier);
    final own = settings.user?.timezone ?? '';
    return TixSection(
      title: l10n.timeZoneTitle,
      subtitle: l10n.timeInForce(
        effective.isEmpty ? 'UTC' : effective,
        timeSourceLabel(l10n, settings.timezoneSource),
      ),
      info: l10n.timeZoneInfo,
      children: [
        Padding(
          padding: const EdgeInsets.all(TixSpace.s3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TixTextField(
                fieldKey: const Key('time.zone'),
                label: l10n.timeZoneLabel,
                controller: _zone,
                hint: 'Europe/Sofia',
                help: l10n.timeZoneHelp,
                enabled: settings.personal,
                autofillHints: const [],
                onSubmitted: (_) =>
                    _save(context, () => notifier.setTimezone(_zone.text)),
              ),
              const SizedBox(height: TixSpace.s3),
              Wrap(
                spacing: TixSpace.s2,
                runSpacing: TixSpace.s2,
                children: [
                  TixButton.primary(
                    key: const Key('time.zoneSave'),
                    label: l10n.timeZoneSave,
                    onPressed: settings.personal
                        ? () => _save(
                            context,
                            () => notifier.setTimezone(_zone.text),
                          )
                        : null,
                  ),
                  if (own.isNotEmpty)
                    TixButton.quiet(
                      key: const Key('time.zoneReset'),
                      label: l10n.timeZoneReset,
                      onPressed: settings.personal
                          ? () => _save(context, () => notifier.setTimezone(''))
                          : null,
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
