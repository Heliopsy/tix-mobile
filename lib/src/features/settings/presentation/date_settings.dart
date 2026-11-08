// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/time/reader_time.dart';
import 'package:tix_mobile/src/core/time/times.dart';

/// The instant every absolute format is shown with, as tix's own chooser
/// does.
final _example = DateTime.utc(2026, 9, 21, 14, 5, 9);

/// The name of the date format [name] in the reader's language.
String timeFormatName(AppLocalizations l10n, String name) => switch (name) {
  'iso' => l10n.timeFormatIso,
  'rfc3339' => l10n.timeFormatRfc3339,
  'short' => l10n.timeFormatShort,
  'long' => l10n.timeFormatLong,
  'dotted' => l10n.timeFormatDotted,
  'dayfirst' => l10n.timeFormatDayfirst,
  'us' => l10n.timeFormatUs,
  'relative' => l10n.timeFormatRelative,
  _ => name,
};

/// Where a value came from, as the web's settings say it.
String timeSourceName(AppLocalizations l10n, String source) => switch (source) {
  'user' => l10n.settingsSourceUser,
  'tenant' => l10n.settingsSourceTenant,
  _ => l10n.settingsSourceGlobal,
};

/// The format [name] with an example of it, in [zone].
String timeFormatLabel(BuildContext context, String name, String zone) {
  final l10n = context.l10n;
  if (name.isEmpty) return l10n.settingsDeviceFormat;
  final times = TixTimes(
    TixTimeStyle.named(
      name,
      zone,
      locale: Localizations.localeOf(context).toLanguageTag(),
    ),
    l10n,
  );
  final now = DateTime.now();
  final sample = name == 'relative'
      ? now.subtract(const Duration(minutes: 18))
      : _example;
  return '${timeFormatName(l10n, name)} (${times.stamp(sample, now: now)})';
}

/// The zone [name] as a reader writes it, or the device's.
String timeZoneLabel(AppLocalizations l10n, String name) {
  if (name.isEmpty || timeZoneNamed(name) == null) {
    return l10n.settingsDeviceZone(DateTime.now().timeZoneName);
  }
  return name.replaceAll('_', ' ');
}

/// The reader's date format and time zone, kept by tix with their account.
class DateFormatSetting extends ConsumerWidget {
  /// Creates the control.
  const DateFormatSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(readerTimeProvider);
    if (settings == null) return const _Unavailable();
    final effective = settings.effective;
    final zone = effective?.timezone ?? '';
    final inherited = _inherited(settings);
    final inUse = l10n.settingsInUse(
      timeFormatLabel(context, effective?.timeFormat ?? '', zone),
      timeSourceName(l10n, settings.formatSource),
    );
    if (!settings.personal) {
      return _Row(
        label: l10n.settingsDateFormat,
        info: l10n.settingsDateFormatHelp,
        help: inUse,
        child: TixNotice(l10n.settingsDatesNotPersonal),
      );
    }
    final held = settings.user?.timeFormat ?? '';
    return Padding(
      padding: const EdgeInsets.all(TixSpace.s3),
      child: TixSelectField<String>(
        key: ValueKey('settings.dateFormat.$held'),
        fieldKey: const Key('settings.dateFormat'),
        label: l10n.settingsDateFormat,
        info: l10n.settingsDateFormatHelp,
        help: inUse,
        value: held,
        options: [
          TixOption(
            '',
            l10n.settingsInheritValue(
              timeFormatLabel(context, inherited.$1, zone),
            ),
          ),
          for (final name in tixTimeFormats)
            TixOption(name, timeFormatLabel(context, name, zone)),
        ],
        onChanged: (v) {
          if (v != null && v != held) _save(context, ref, format: v);
        },
      ),
    );
  }
}

/// The reader's time zone, kept by tix with their account.
class TimeZoneSetting extends ConsumerWidget {
  /// Creates the control.
  const TimeZoneSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(readerTimeProvider);
    if (settings == null) return const SizedBox.shrink();
    final held = settings.user?.timezone ?? '';
    final inUse = l10n.settingsInUse(
      timeZoneLabel(l10n, settings.effective?.timezone ?? ''),
      timeSourceName(l10n, settings.timezoneSource),
    );
    final inherited = timeZoneLabel(l10n, _inherited(settings).$2);
    return ListTile(
      key: const Key('settings.timeZone'),
      leading: const Icon(Icons.public),
      title: Row(
        children: [
          Flexible(child: Text(l10n.settingsTimeZone)),
          InfoTip(l10n.settingsTimeZoneHelp, size: TixSize.controlSmall),
        ],
      ),
      subtitle: Text(
        [
          if (settings.personal)
            held.isEmpty
                ? l10n.settingsInheritValue(inherited)
                : timeZoneLabel(l10n, held),
          inUse,
        ].join('\n'),
      ),
      trailing: settings.personal ? const Icon(Icons.chevron_right) : null,
      onTap: !settings.personal
          ? null
          : () async {
              final picked = await showTixSheet<String>(
                context,
                builder: (_) => _ZoneSheet(held: held, inherited: inherited),
              );
              if (picked != null && context.mounted) {
                await _save(context, ref, timezone: picked);
              }
            },
    );
  }
}

/// What the reader would get without a choice of their own: the tenant's,
/// else the deployment's format and zone.
(String, String) _inherited(TimeSettings s) {
  String pick(String? tenant, String? global) =>
      (tenant ?? '').isNotEmpty ? tenant! : (global ?? '');
  return (
    pick(s.tenant?.timeFormat, s.global?.timeFormat),
    pick(s.tenant?.timezone, s.global?.timezone),
  );
}

Future<void> _save(
  BuildContext context,
  WidgetRef ref, {
  String? format,
  String? timezone,
}) async {
  final l10n = context.l10n;
  try {
    await ref
        .read(readerTimeProvider.notifier)
        .set(format: format, timezone: timezone);
    if (context.mounted) showTixToast(context, l10n.settingsDatesSaved);
  } on Object catch (e) {
    if (context.mounted) {
      showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
    }
  }
}

class _Unavailable extends ConsumerWidget {
  const _Unavailable();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.all(TixSpace.s3),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TixNotice(context.l10n.settingsDatesUnavailable),
        const SizedBox(height: TixSpace.s2),
        TixButton(
          key: const Key('settings.datesRetry'),
          label: context.l10n.retry,
          icon: Icons.refresh,
          size: TixButtonSize.small,
          onPressed: () => ref.read(readerTimeProvider.notifier).refresh(),
        ),
      ],
    ),
  );
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.info,
    required this.help,
    required this.child,
  });

  final String label;
  final String info;
  final String help;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(TixSpace.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: TixText.xs,
                    fontWeight: FontWeight.w500,
                    color: context.tix.muted,
                  ),
                ),
              ),
              InfoTip(info, size: TixSize.controlSmall),
            ],
          ),
          Text(help, style: theme.textTheme.bodySmall),
          const SizedBox(height: TixSpace.s2),
          child,
        ],
      ),
    );
  }
}

class _ZoneSheet extends StatefulWidget {
  const _ZoneSheet({required this.held, required this.inherited});

  final String held;
  final String inherited;

  @override
  State<_ZoneSheet> createState() => _ZoneSheetState();
}

class _ZoneSheetState extends State<_ZoneSheet> {
  late final List<String> _zones = timeZoneNames();
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final q = _query.trim().toLowerCase().replaceAll(' ', '_');
    final shown = [
      for (final z in _zones)
        if (q.isEmpty || z.toLowerCase().contains(q)) z,
    ];
    return TixSheetBody(
      title: l10n.settingsTimeZone,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TixSearchField(
            fieldKey: const Key('settings.zoneSearch'),
            hint: l10n.settingsZoneSearch,
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: TixSpace.s2),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.5,
            child: ListView(
              children: [
                if (q.isEmpty)
                  _ZoneTile(
                    key: const Key('zone.inherit'),
                    label: l10n.settingsInheritValue(widget.inherited),
                    selected: widget.held.isEmpty,
                    onTap: () => Navigator.of(context).pop(''),
                  ),
                for (final z in shown)
                  _ZoneTile(
                    key: Key('zone.$z'),
                    label: z.replaceAll('_', ' '),
                    selected: z == widget.held,
                    onTap: () => Navigator.of(context).pop(z),
                  ),
                if (shown.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(TixSpace.s3),
                    child: Text(l10n.settingsZoneNone),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneTile extends StatelessWidget {
  const _ZoneTile({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(label),
    selected: selected,
    trailing: selected ? const Icon(Icons.check) : null,
    onTap: onTap,
  );
}
