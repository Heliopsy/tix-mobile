// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/settings/application/settings.dart';

/// Language names as their own readers write them, as tix's web app does.
const languageNames = {'en': 'English', 'bg': 'Български'};

/// Theme, language and the saved servers.
class SettingsScreen extends ConsumerWidget {
  /// Creates the screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeSettingProvider);
    final locale = ref.watch(localeSettingProvider);
    final session = ref.watch(sessionControllerProvider).value;
    final contexts = ref.watch(savedContextsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          _SectionHeading(l10n.themeLabel),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              key: const Key('settings.theme'),
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(l10n.themeSystem),
                  icon: const Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(l10n.themeLight),
                  icon: const Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(l10n.themeDark),
                  icon: const Icon(Icons.dark_mode),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (s) =>
                  ref.read(themeModeSettingProvider.notifier).set(s.first),
            ),
          ),
          _SectionHeading(l10n.languageLabel),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<String>(
              key: const Key('settings.language'),
              segments: [
                ButtonSegment(value: '', label: Text(l10n.languageSystem)),
                for (final MapEntry(:key, :value) in languageNames.entries)
                  ButtonSegment(value: key, label: Text(value)),
              ],
              selected: {locale?.languageCode ?? ''},
              onSelectionChanged: (s) => ref
                  .read(localeSettingProvider.notifier)
                  .set(s.first.isEmpty ? null : Locale(s.first)),
            ),
          ),
          _SectionHeading(l10n.serversLabel),
          for (final c in contexts)
            ListTile(
              key: Key('settings.server.${c.id}'),
              leading: Icon(
                c.id == session?.context.id
                    ? Icons.check_circle
                    : Icons.dns_outlined,
              ),
              title: Text(c.name),
              subtitle: Text(
                c.handle.isEmpty ? c.baseUrl : '@${c.handle} · ${c.baseUrl}',
              ),
              selected: c.id == session?.context.id,
              onTap: c.id == session?.context.id
                  ? null
                  : () => ref
                        .read(sessionControllerProvider.notifier)
                        .switchTo(c.id),
            ),
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(l10n.addServer),
            onTap: () => context.go(Routes.addServer),
          ),
          if (session != null)
            ListTile(
              key: const Key('settings.signOut'),
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              title: Text(
                l10n.signOut,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              subtitle: session.context.handle.isEmpty
                  ? null
                  : Text(l10n.signedInAs('@${session.context.handle}')),
              onTap: () => _confirmSignOut(context, ref, session.context.name),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(
    BuildContext context,
    WidgetRef ref,
    String server,
  ) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signOut),
        content: Text(l10n.signOutBody(server)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const Key('settings.signOut.confirm'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await ref.read(sessionControllerProvider.notifier).signOut();
    }
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
