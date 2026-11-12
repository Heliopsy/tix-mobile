// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/colour.dart' show parseHex;
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/design/theme.dart';
import 'package:tix_mobile/src/core/l10n/durations.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/admin.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/features/admin/application/tenant_admin.dart';

/// The date formats a tenant can choose, as tix names them; empty
/// inherits the server's.
const timeFormats = [
  '',
  'iso',
  'rfc3339',
  'short',
  'long',
  'dotted',
  'dayfirst',
  'us',
  'relative',
];

/// A tenant's settings: name, theme with a live preview, the date
/// defaults, second-factor requirements, claim leases, sessions, artifact
/// limits, the trash, and deleting it. Without [tenantRef] it is the
/// active tenant's.
class TenantSettingsScreen extends ConsumerWidget {
  /// The settings of [tenantRef], or of the active tenant.
  const TenantSettingsScreen({this.tenantRef, super.key});

  /// The tenant, by key or id; null for the active one.
  final String? tenantRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final given = tenantRef;
    final target = given == null
        ? ref.watch(currentTenantRefProvider)
        : AsyncData(given);
    final tenant = target.whenData((r) => ref.watch(tenantSettingsProvider(r)));
    final loaded = switch (tenant) {
      AsyncData(:final value) => value,
      AsyncError(:final error, :final stackTrace) => AsyncError<Tenant>(
        error,
        stackTrace,
      ),
      _ => const AsyncLoading<Tenant>(),
    };
    final name = loaded.value?.name;
    return TixPage(
      title: l10n.tenantSettingsTitle,
      subtitle: name == null ? null : '$name · ${loaded.value!.key}',
      body: AsyncBody(
        value: loaded,
        onRetry: () {
          if (given == null) ref.invalidate(currentTenantRefProvider);
          final r = target.value;
          if (r != null) ref.invalidate(tenantSettingsProvider(r));
        },
        data: (t) => _TenantSettingsBody(
          tenantRef: target.value!,
          tenant: t,
          current: given == null,
        ),
      ),
    );
  }
}

class _TenantSettingsBody extends ConsumerWidget {
  const _TenantSettingsBody({
    required this.tenantRef,
    required this.tenant,
    required this.current,
  });

  final String tenantRef;
  final Tenant tenant;
  final bool current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    Future<void> save(UpdateTenantInput input, {String? done}) async {
      try {
        await ref.read(tenantSettingsProvider(tenantRef).notifier).save(input);
        if (context.mounted) showTixToast(context, done ?? l10n.tenantSaved);
      } on Object catch (e) {
        if (context.mounted) {
          showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
        }
        rethrow;
      }
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(tenantSettingsProvider(tenantRef).future),
      child: ListView(
        padding: const EdgeInsets.only(bottom: TixSpace.s7),
        children: [
          _GeneralSection(tenant: tenant, save: save),
          _ThemeSection(tenant: tenant, save: save),
          TixSection(
            title: l10n.tenantTotpTitle,
            info: l10n.tenantTotpInfo,
            children: [
              TixSwitchRow(
                key: const Key('tenant.totpWeb'),
                title: l10n.tenantTotpWeb,
                value: tenant.requireTotpWeb,
                onChanged: (v) =>
                    _quiet(save(UpdateTenantInput(requireTotpWeb: v))),
              ),
              TixSwitchRow(
                key: const Key('tenant.totpCli'),
                title: l10n.tenantTotpCli,
                value: tenant.requireTotpCli,
                onChanged: (v) =>
                    _quiet(save(UpdateTenantInput(requireTotpCli: v))),
              ),
              TixSwitchRow(
                key: const Key('tenant.totpSsh'),
                title: l10n.tenantTotpSsh,
                value: tenant.requireTotpSsh,
                onChanged: (v) =>
                    _quiet(save(UpdateTenantInput(requireTotpSsh: v))),
              ),
            ],
          ),
          _LeaseSection(tenant: tenant, save: save),
          _SessionSection(
            tenant: tenant,
            server: ref.watch(serverSessionPolicyProvider).value,
            save: save,
          ),
          _ArtifactSection(
            tenant: tenant,
            server: ref.watch(serverArtifactLimitsProvider).value,
            save: save,
          ),
          TixSection(
            title: l10n.tenantTrashTitle,
            children: [
              TixSwitchRow(
                key: const Key('tenant.trash'),
                title: l10n.tenantTrashKeep,
                subtitle: tenant.trashOff
                    ? l10n.tenantTrashOffBody
                    : l10n.tenantTrashOnBody,
                value: !tenant.trashOff,
                onChanged: (v) => _quiet(save(UpdateTenantInput(trashOff: !v))),
              ),
            ],
          ),
          TixSection(
            title: l10n.manageDangerZone,
            danger: true,
            children: [
              ListTile(
                title: Text(l10n.tenantDelete),
                subtitle: Text(l10n.tenantDeleteHelp),
                trailing: TixButton.danger(
                  key: const Key('tenant.delete'),
                  label: l10n.manageDelete,
                  size: TixButtonSize.small,
                  onPressed: () => _delete(context, ref),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _quiet(Future<void> f) => f.ignore();

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.tenantDelete,
      body: l10n.tenantDeleteBody(tenant.name, tenant.key),
      action: l10n.tenantDelete,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(tenantSettingsProvider(tenantRef).notifier).delete();
    } on Object catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
      return;
    }
    if (!context.mounted) return;
    showTixToast(context, l10n.tenantDeleted(tenant.name));
    if (current) {
      await ref.read(sessionControllerProvider.notifier).signOut();
    } else {
      context.go(Routes.manageTenants);
    }
  }
}

typedef _Save = Future<void> Function(UpdateTenantInput input, {String? done});

/// A section whose fields are sent together by its own Save button.
class _FormSection extends StatefulWidget {
  const _FormSection({
    required this.title,
    required this.dirty,
    required this.onSave,
    required this.children,
    this.info,
    this.saveKey,
  });

  final String title;
  final String? info;
  final bool dirty;
  final Future<void> Function() onSave;
  final List<Widget> children;
  final Key? saveKey;

  @override
  State<_FormSection> createState() => _FormSectionState();
}

class _FormSectionState extends State<_FormSection> {
  var _busy = false;

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await widget.onSave();
    } on Object {
      // The toast has said why; the fields keep what was typed.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => TixSection(
    title: widget.title,
    info: widget.info,
    children: [
      Padding(
        padding: const EdgeInsets.all(TixSpace.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...widget.children,
            const SizedBox(height: TixSpace.s3),
            TixButton(
              key: widget.saveKey,
              label: context.l10n.manageSave,
              icon: Icons.check,
              busy: _busy,
              onPressed: widget.dirty ? _save : null,
            ),
          ],
        ),
      ),
    ],
  );
}

class _GeneralSection extends StatefulWidget {
  const _GeneralSection({required this.tenant, required this.save});

  final Tenant tenant;
  final _Save save;

  @override
  State<_GeneralSection> createState() => _GeneralSectionState();
}

class _GeneralSectionState extends State<_GeneralSection> {
  late final _name = TextEditingController(text: widget.tenant.name);
  late final _zone = TextEditingController(text: widget.tenant.timezone);
  late String _format = widget.tenant.timeFormat;

  @override
  void didUpdateWidget(_GeneralSection old) {
    super.didUpdateWidget(old);
    if (old.tenant.name != widget.tenant.name) {
      _name.text = widget.tenant.name;
    }
    if (old.tenant.timezone != widget.tenant.timezone) {
      _zone.text = widget.tenant.timezone;
    }
    if (old.tenant.timeFormat != widget.tenant.timeFormat) {
      _format = widget.tenant.timeFormat;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _zone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = widget.tenant;
    final name = _name.text.trim();
    final zone = _zone.text.trim();
    final dirty =
        name != t.name || zone != t.timezone || _format != t.timeFormat;
    return _FormSection(
      title: l10n.tenantGeneralTitle,
      dirty: dirty,
      saveKey: const Key('tenant.general.save'),
      onSave: () => widget.save(
        UpdateTenantInput(
          name: name == t.name ? null : name,
          timezone: zone == t.timezone ? null : zone,
          timeFormat: _format == t.timeFormat ? null : _format,
        ),
      ),
      children: [
        TixTextField(
          fieldKey: const Key('tenant.name'),
          label: l10n.tenantName,
          controller: _name,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: TixSpace.s3),
        TixTextField(
          fieldKey: const Key('tenant.timezone'),
          label: l10n.tenantTimezone,
          hint: 'Europe/Sofia',
          help: l10n.tenantTimezoneHelp,
          controller: _zone,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: TixSpace.s3),
        Text(
          l10n.tenantTimeFormat,
          style: TextStyle(
            fontSize: TixText.xs,
            fontWeight: FontWeight.w500,
            color: context.tix.muted,
          ),
        ),
        const SizedBox(height: TixSpace.s1),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: TixMeasure.field),
          child: DropdownButtonFormField<String>(
            key: const Key('tenant.timeFormat'),
            initialValue: timeFormats.contains(_format) ? _format : '',
            items: [
              for (final f in timeFormats)
                DropdownMenuItem(
                  value: f,
                  child: Text(f.isEmpty ? l10n.tenantServerDefault : f),
                ),
            ],
            onChanged: (v) => setState(() => _format = v ?? ''),
          ),
        ),
      ],
    );
  }
}

class _ThemeSection extends StatefulWidget {
  const _ThemeSection({required this.tenant, required this.save});

  final Tenant tenant;
  final _Save save;

  @override
  State<_ThemeSection> createState() => _ThemeSectionState();
}

class _ThemeSectionState extends State<_ThemeSection> {
  late String _draft = widget.tenant.theme;
  late final _custom = TextEditingController(
    text: parseHex(widget.tenant.theme) == null ? '' : widget.tenant.theme,
  );

  @override
  void didUpdateWidget(_ThemeSection old) {
    super.didUpdateWidget(old);
    if (old.tenant.theme != widget.tenant.theme) _draft = widget.tenant.theme;
  }

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final saved = widget.tenant.theme;
    final accent = TixAccent.resolve(_draft);
    final customBad =
        _custom.text.trim().isNotEmpty && parseHex(_custom.text) == null;
    return _FormSection(
      title: l10n.tenantThemeTitle,
      info: l10n.tenantThemeInfo,
      dirty: _draft.trim().toLowerCase() != saved.trim().toLowerCase(),
      saveKey: const Key('tenant.theme.save'),
      onSave: () => widget.save(
        UpdateTenantInput(theme: _draft.trim().toLowerCase()),
        done: l10n.tenantThemeSaved,
      ),
      children: [
        Wrap(
          spacing: TixSpace.s2,
          runSpacing: TixSpace.s2,
          children: [
            for (final a in TixAccent.builtIn)
              _Swatch(
                key: Key('theme.${a.name}'),
                accent: a,
                label: a == TixAccent.standard
                    ? l10n.tenantThemeDefault
                    : a.name,
                selected: accent.name == a.name,
                onTap: () => setState(() {
                  _draft = a == TixAccent.standard ? '' : a.name;
                  _custom.clear();
                }),
              ),
          ],
        ),
        const SizedBox(height: TixSpace.s3),
        TixTextField(
          fieldKey: const Key('tenant.customColour'),
          label: l10n.tenantThemeCustom,
          hint: '#0f766e',
          help: l10n.tenantThemeCustomHelp,
          error: customBad ? l10n.tenantThemeCustomBad : null,
          controller: _custom,
          onChanged: (v) => setState(() {
            if (parseHex(v) != null) _draft = v.trim().toLowerCase();
          }),
        ),
        const SizedBox(height: TixSpace.s4),
        Text(
          l10n.tenantThemePreview,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: TixSpace.s2),
        Wrap(
          key: const Key('tenant.preview'),
          spacing: TixSpace.s3,
          runSpacing: TixSpace.s3,
          children: [
            for (final b in [Brightness.light, Brightness.dark])
              ThemePreview(accent: accent, brightness: b),
          ],
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.accent,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final TixAccent accent;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      selected: selected,
      button: true,
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => onTap(),
        avatar: CircleAvatar(
          backgroundColor: dark ? accent.accentDark : accent.accent,
          radius: 8,
        ),
        label: Text(label),
      ),
    );
  }
}

/// A small page drawn in [accent] and [brightness], the way the app looks
/// once the tenant takes that theme: a primary button, a link, a selected
/// row on its tint and a status that keeps tix's own colour.
class ThemePreview extends StatelessWidget {
  /// Previews [accent] in [brightness].
  const ThemePreview({
    required this.accent,
    required this.brightness,
    super.key,
  });

  /// The accent to show.
  final TixAccent accent;

  /// The scheme to show it in.
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = buildTixTheme(brightness, accent: accent);
    return Theme(
      data: theme,
      child: Builder(
        builder: (context) {
          final t = context.tix;
          return Container(
            key: Key('preview.${brightness.name}'),
            width: 260,
            padding: const EdgeInsets.all(TixSpace.s3),
            decoration: BoxDecoration(
              color: t.bg,
              border: Border.all(color: t.line),
              borderRadius: BorderRadius.circular(TixRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brightness == Brightness.light
                      ? l10n.themeLight
                      : l10n.themeDark,
                  style: TextStyle(color: t.muted, fontSize: TixText.xs),
                ),
                const SizedBox(height: TixSpace.s2),
                Container(
                  padding: const EdgeInsets.all(TixSpace.s2),
                  decoration: BoxDecoration(
                    color: t.accentSoft,
                    borderRadius: BorderRadius.circular(TixRadius.md),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: t.accent, size: 16),
                      const SizedBox(width: TixSpace.s2),
                      Expanded(
                        child: Text(
                          l10n.tenantThemeSampleRow,
                          style: TextStyle(color: t.ink),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: TixSpace.s2),
                Text(
                  l10n.tenantThemeSampleLink,
                  style: TextStyle(
                    color: t.accent,
                    decoration: TextDecoration.underline,
                    decorationColor: t.accent,
                  ),
                ),
                const SizedBox(height: TixSpace.s2),
                Wrap(
                  spacing: TixSpace.s2,
                  runSpacing: TixSpace.s2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TixButton.primary(
                      label: l10n.tenantThemeSampleButton,
                      icon: Icons.add,
                      size: TixButtonSize.small,
                      onPressed: () {},
                    ),
                    StatusPill(
                      label: l10n.tenantThemeSampleStatus,
                      category: StatusCategory.inProgress,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LeaseSection extends StatefulWidget {
  const _LeaseSection({required this.tenant, required this.save});

  final Tenant tenant;
  final _Save save;

  @override
  State<_LeaseSection> createState() => _LeaseSectionState();
}

class _LeaseSectionState extends State<_LeaseSection> {
  late final _default = TextEditingController(text: widget.tenant.leaseDefault);
  late final _max = TextEditingController(text: widget.tenant.leaseMax);

  @override
  void didUpdateWidget(_LeaseSection old) {
    super.didUpdateWidget(old);
    if (old.tenant.leaseDefault != widget.tenant.leaseDefault) {
      _default.text = widget.tenant.leaseDefault;
    }
    if (old.tenant.leaseMax != widget.tenant.leaseMax) {
      _max.text = widget.tenant.leaseMax;
    }
  }

  @override
  void dispose() {
    _default.dispose();
    _max.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = widget.tenant;
    final d = _default.text.trim();
    final m = _max.text.trim();
    return _FormSection(
      title: l10n.tenantLeaseTitle,
      info: l10n.tenantLeaseInfo,
      dirty: d != t.leaseDefault || m != t.leaseMax,
      saveKey: const Key('tenant.lease.save'),
      onSave: () => widget.save(
        UpdateTenantInput(
          leaseDefault: d == t.leaseDefault ? null : (d.isEmpty ? '0' : d),
          leaseMax: m == t.leaseMax ? null : (m.isEmpty ? '0' : m),
        ),
      ),
      children: [
        TixTextField(
          fieldKey: const Key('tenant.leaseDefault'),
          label: l10n.tenantLeaseDefault,
          hint: '30m',
          help: l10n.tenantLeaseDefaultHelp,
          controller: _default,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: TixSpace.s3),
        TixTextField(
          fieldKey: const Key('tenant.leaseMax'),
          label: l10n.tenantLeaseMax,
          hint: '4h',
          help: l10n.tenantLeaseMaxHelp,
          controller: _max,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }
}

/// [goText], a duration as tix sends it ("8h0m0s"), written the way tix
/// reads it back ("8h", "1d 12h"); empty for none or zero.
String durationField(String goText) {
  final d = parseGoDuration(goText);
  if (d == null) return goText;
  if (d <= Duration.zero) return '';
  final parts = [
    if (d.inDays > 0) '${d.inDays}d',
    if (d.inHours % 24 > 0) '${d.inHours % 24}h',
    if (d.inMinutes % 60 > 0) '${d.inMinutes % 60}m',
    if (d.inSeconds % 60 > 0) '${d.inSeconds % 60}s',
  ];
  return parts.join(' ');
}

const _byteUnits = [(30, 'GiB'), (20, 'MiB'), (10, 'KiB')];

/// [bytes] in the largest binary unit that divides it ("5MiB"), else as a
/// bare count; empty for zero.
String byteSizeField(int bytes) {
  if (bytes <= 0) return '';
  for (final (shift, name) in _byteUnits) {
    final size = 1 << shift;
    if (bytes >= size && bytes % size == 0) return '${bytes ~/ size}$name';
  }
  return '$bytes';
}

/// A size as tix's ParseByteSize reads one ("512KiB", "5 MiB", "2M", a bare
/// count of bytes, binary units throughout), zero for empty, or null when
/// [text] is not a size.
int? parseByteSize(String text) {
  var t = text.replaceAll(' ', '').toUpperCase();
  if (t.isEmpty) return 0;
  if (t.endsWith('IB')) {
    t = t.substring(0, t.length - 2);
  } else if (t.endsWith('B')) {
    t = t.substring(0, t.length - 1);
  }
  var shift = 0;
  for (final (unit, s) in [('K', 10), ('M', 20), ('G', 30)]) {
    if (t.endsWith(unit)) {
      shift = s;
      t = t.substring(0, t.length - 1);
    }
  }
  if (!RegExp(r'^\d+$').hasMatch(t)) return null;
  final n = int.tryParse(t);
  if (n == null || n > (1 << 62) >> shift) return null;
  return n << shift;
}

List<String> _splitTypes(String text) => [
  for (final p in text.split(RegExp(r'[,\s]+')))
    if (p.isNotEmpty) p,
];

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: TixSpace.s3),
    child: Text(
      text,
      style: TextStyle(fontSize: TixText.xs, color: context.tix.muted),
    ),
  );
}

class _SessionSection extends StatefulWidget {
  const _SessionSection({
    required this.tenant,
    required this.server,
    required this.save,
  });

  final Tenant tenant;

  /// The server's own settings, the hints for empty fields; null while
  /// unknown.
  final SessionPolicy? server;
  final _Save save;

  @override
  State<_SessionSection> createState() => _SessionSectionState();
}

class _SessionSectionState extends State<_SessionSection> {
  late String _ttlSaved;
  late String _idleSaved;
  late String _rememberSaved;
  final _ttl = TextEditingController();
  final _idle = TextEditingController();
  final _remember = TextEditingController();

  static String _rememberText(Tenant t) =>
      t.sessionRememberOff ? 'off' : durationField(t.sessionRememberTtl);

  void _load(Tenant t, {Tenant? old}) {
    final ttl = durationField(t.sessionTtl);
    final idle = durationField(t.sessionIdleTimeout);
    final remember = _rememberText(t);
    if (old == null || durationField(old.sessionTtl) != ttl) _ttl.text = ttl;
    if (old == null || durationField(old.sessionIdleTimeout) != idle) {
      _idle.text = idle;
    }
    if (old == null || _rememberText(old) != remember) {
      _remember.text = remember;
    }
    _ttlSaved = ttl;
    _idleSaved = idle;
    _rememberSaved = remember;
  }

  @override
  void initState() {
    super.initState();
    _load(widget.tenant);
  }

  @override
  void didUpdateWidget(_SessionSection old) {
    super.didUpdateWidget(old);
    _load(widget.tenant, old: old.tenant);
  }

  @override
  void dispose() {
    _ttl.dispose();
    _idle.dispose();
    _remember.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final server = widget.server;
    String hintOf(String? goText, {required String example, String? off}) {
      if (goText == null) return example;
      final text = durationField(goText);
      return text.isNotEmpty ? text : (off ?? example);
    }

    final ttlHint = hintOf(server?.serverTtl, example: '8h');
    final idleHint = hintOf(
      server?.serverIdleTimeout,
      example: '30m',
      off: l10n.tenantSessionNever,
    );
    final rememberHint = hintOf(
      server?.serverRememberTtl,
      example: '7d',
      off: 'off',
    );
    final ttl = _ttl.text.trim();
    final idle = _idle.text.trim();
    final remember = _remember.text.trim();
    return _FormSection(
      title: l10n.tenantSessionTitle,
      info: l10n.tenantSessionInfo,
      dirty:
          ttl != _ttlSaved || idle != _idleSaved || remember != _rememberSaved,
      saveKey: const Key('tenant.session.save'),
      onSave: () => widget.save(
        UpdateTenantInput(
          sessionTtl: ttl == _ttlSaved ? null : (ttl.isEmpty ? '0' : ttl),
          sessionIdleTimeout: idle == _idleSaved
              ? null
              : (idle.isEmpty ? '0' : idle),
          sessionRememberTtl: remember == _rememberSaved ? null : remember,
        ),
      ),
      children: [
        TixTextField(
          fieldKey: const Key('tenant.sessionTtl'),
          label: l10n.tenantSessionTtl,
          hint: ttlHint,
          info: l10n.tenantSessionTtlInfo,
          controller: _ttl,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: TixSpace.s3),
        TixTextField(
          fieldKey: const Key('tenant.sessionIdle'),
          label: l10n.tenantSessionIdle,
          hint: idleHint,
          info: l10n.tenantSessionIdleInfo,
          controller: _idle,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: TixSpace.s3),
        TixTextField(
          fieldKey: const Key('tenant.sessionRemember'),
          label: l10n.tenantSessionRemember,
          hint: rememberHint,
          info: l10n.tenantSessionRememberInfo,
          controller: _remember,
          onChanged: (_) => setState(() {}),
        ),
        _Note(l10n.tenantSessionNote),
      ],
    );
  }
}

class _ArtifactSection extends StatefulWidget {
  const _ArtifactSection({
    required this.tenant,
    required this.server,
    required this.save,
  });

  final Tenant tenant;

  /// The server's own limits, the hints for empty fields; null while
  /// unknown.
  final ArtifactLimits? server;
  final _Save save;

  @override
  State<_ArtifactSection> createState() => _ArtifactSectionState();
}

class _ArtifactSectionState extends State<_ArtifactSection> {
  late final _size = TextEditingController(
    text: byteSizeField(widget.tenant.artifactMaxBytes),
  );
  late final _types = TextEditingController(
    text: widget.tenant.artifactTypes.join(', '),
  );

  @override
  void didUpdateWidget(_ArtifactSection old) {
    super.didUpdateWidget(old);
    if (old.tenant.artifactMaxBytes != widget.tenant.artifactMaxBytes) {
      _size.text = byteSizeField(widget.tenant.artifactMaxBytes);
    }
    if (!listEquals(old.tenant.artifactTypes, widget.tenant.artifactTypes)) {
      _types.text = widget.tenant.artifactTypes.join(', ');
    }
  }

  @override
  void dispose() {
    _size.dispose();
    _types.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = widget.tenant;
    final server = widget.server;
    final serverSize = byteSizeField(server?.serverMaxBytes ?? 0);
    final serverTypes = (server?.serverAllowedTypes ?? const []).join(', ');
    final size = parseByteSize(_size.text);
    final types = _splitTypes(_types.text);
    final sizeChanged = size != null && size != t.artifactMaxBytes;
    final typesChanged = !listEquals(types, t.artifactTypes);
    return _FormSection(
      title: l10n.tenantArtifactTitle,
      info: l10n.tenantArtifactInfo,
      dirty: size != null && (sizeChanged || typesChanged),
      saveKey: const Key('tenant.artifact.save'),
      onSave: () => widget.save(
        UpdateTenantInput(
          artifactMaxBytes: sizeChanged ? size : null,
          artifactTypes: typesChanged ? types : null,
        ),
      ),
      children: [
        TixTextField(
          fieldKey: const Key('tenant.artifactMaxBytes'),
          label: l10n.tenantArtifactMaxBytes,
          hint: serverSize.isEmpty ? '5MiB' : serverSize,
          info: l10n.tenantArtifactMaxBytesInfo,
          error: size == null ? l10n.tenantArtifactSizeBad : null,
          controller: _size,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: TixSpace.s3),
        TixTextField(
          fieldKey: const Key('tenant.artifactTypes'),
          label: l10n.tenantArtifactTypes,
          hint: serverTypes.isEmpty ? 'image/*, application/pdf' : serverTypes,
          info: l10n.tenantArtifactTypesInfo,
          controller: _types,
          onChanged: (_) => setState(() {}),
        ),
        _Note(l10n.tenantArtifactNote),
      ],
    );
  }
}
