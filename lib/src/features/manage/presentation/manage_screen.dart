// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/session/access.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/features/manage/manage_sections.dart';

/// The heading of [group].
String manageGroupTitle(AppLocalizations l10n, ManageGroup group) =>
    switch (group) {
      ManageGroup.projects => l10n.manageGroupProjects,
      ManageGroup.workflows => l10n.manageGroupWorkflows,
      ManageGroup.fields => l10n.manageGroupFields,
      ManageGroup.people => l10n.manageGroupPeople,
      ManageGroup.access => l10n.manageGroupAccess,
      ManageGroup.tenant => l10n.manageGroupTenant,
      ManageGroup.server => l10n.manageGroupServer,
    };

/// Every management area the active credential can use, grouped.
class ManageScreen extends ConsumerWidget {
  /// Creates the screen.
  const ManageScreen({this.entries, super.key});

  /// The entries to offer; [manageSections] when null.
  final List<ManageEntry>? entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).value;
    final tenant = session?.connection.tenantLabel ?? '';
    return TixPage(
      title: l10n.manageTitle,
      subtitle: tenant.isEmpty ? null : l10n.manageSubtitle(tenant),
      body: AsyncBody(
        value: ref.watch(currentAccessProvider),
        onRetry: () => ref.invalidate(currentAccessProvider),
        data: (access) =>
            _Groups(access: access, entries: entries ?? manageSections),
      ),
    );
  }
}

class _Groups extends StatelessWidget {
  const _Groups({required this.access, required this.entries});

  final Access access;
  final List<ManageEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final visible = [
      for (final e in entries)
        if (e.visibleTo(access)) e,
    ];
    if (visible.isEmpty) {
      return EmptyState(
        icon: Icons.admin_panel_settings_outlined,
        title: l10n.manageEmpty,
        body: l10n.manageEmptyBody,
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: TixSpace.s6),
      children: [
        for (final group in ManageGroup.values)
          if (visible.any((e) => e.group == group))
            Align(
              alignment: AlignmentDirectional.topStart,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: TixMeasure.form),
                child: TixSection(
                  key: Key('manage.group.${group.name}'),
                  title: manageGroupTitle(l10n, group),
                  children: [
                    for (final e in visible)
                      if (e.group == group) _EntryTile(entry: e),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final ManageEntry entry;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final l10n = context.l10n;
    return ListTile(
      key: Key('manage.${entry.id}'),
      leading: Icon(entry.icon, color: t.muted),
      title: Text(entry.title(l10n)),
      subtitle: Text(entry.subtitle(l10n)),
      trailing: Icon(Icons.chevron_right, color: t.lineStrong),
      onTap: () => context.go(entry.route),
    );
  }
}
