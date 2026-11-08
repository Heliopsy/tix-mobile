// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/admin.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/features/admin/application/global_admin.dart';
import 'package:tix_mobile/src/features/admin/application/tenant_admin.dart';
import 'package:tix_mobile/src/features/admin/presentation/domains_screen.dart';

/// One tenant on its own screen, as a phone opens it from the list.
class TenantDetailScreen extends ConsumerWidget {
  /// The tenant [tenantKey].
  const TenantDetailScreen({required this.tenantKey, super.key});

  /// The tenant's key.
  final String tenantKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenant = ref.watch(tenantSettingsProvider(tenantKey)).value;
    return TixPage(
      title: tenant?.name ?? tenantKey,
      subtitle: tenantKey,
      body: TenantDetail(tenantKey: tenantKey, header: false),
    );
  }
}

/// What a global admin sees of one tenant: its facts, switching into it,
/// its settings and users, its domains and deleting it.
class TenantDetail extends ConsumerWidget {
  /// The tenant [tenantKey]; [header] draws its name above, for the pane
  /// beside the list.
  const TenantDetail({required this.tenantKey, this.header = true, super.key});

  /// The tenant's key.
  final String tenantKey;

  /// Whether to draw the tenant's name as a header.
  final bool header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(tenantSettingsProvider(tenantKey));
    return AsyncBody(
      value: value,
      onRetry: () => ref.invalidate(tenantSettingsProvider(tenantKey)),
      data: (tenant) => ListView(
        padding: const EdgeInsets.only(bottom: TixSpace.s7),
        children: [
          if (header)
            TixPageHeader(
              title: tenant.name.isEmpty ? tenant.key : tenant.name,
              subtitle: tenant.key,
            ),
          _Overview(tenant: tenant),
          _Domains(tenantKey: tenantKey),
          _Danger(tenant: tenant),
        ],
      ),
    );
  }
}

class _Overview extends ConsumerWidget {
  const _Overview({required this.tenant});

  final Tenant tenant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final created = tenant.createdAt;
    final totp = [
      if (tenant.requireTotpWeb) l10n.totpSurfaceWeb,
      if (tenant.requireTotpCli) l10n.totpSurfaceCli,
      if (tenant.requireTotpSsh) l10n.totpSurfaceSsh,
    ];
    return TixSection(
      title: l10n.tenantOverview,
      children: [
        TixPropertyList(
          children: [
            TixPropertyRow(
              label: l10n.tenantKey,
              child: Text(
                tenant.key,
                style: tixMono(context, size: TixText.sm),
              ),
            ),
            TixPropertyRow(
              label: l10n.tenantThemeTitle,
              child: Text(
                tenant.theme.isEmpty ? l10n.tenantThemeDefault : tenant.theme,
              ),
            ),
            TixPropertyRow(
              label: l10n.tenantTotpTitle,
              child: Text(totp.isEmpty ? l10n.tenantTotpNone : totp.join(', ')),
            ),
            TixPropertyRow(
              label: l10n.tenantTrashTitle,
              child: Text(
                tenant.trashOff
                    ? l10n.tenantTrashOffShort
                    : l10n.tenantTrashOnShort,
              ),
            ),
            if (created != null)
              TixPropertyRow(
                label: l10n.tenantCreatedAt,
                child: Text(context.times.style.date(created)),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(TixSpace.s4),
          child: Wrap(
            spacing: TixSpace.s2,
            runSpacing: TixSpace.s2,
            children: [
              _SwitchButton(tenant: tenant),
              TixButton(
                key: const Key('tenant.settings'),
                label: l10n.tenantSettingsTitle,
                icon: Icons.tune,
                onPressed: () =>
                    context.push(Routes.manageTenantSettings(tenant.key)),
              ),
              TixButton(
                key: const Key('tenant.users'),
                label: l10n.tenantUsersTitle,
                icon: Icons.people_outline,
                onPressed: () =>
                    context.push(Routes.manageTenantUsers(tenant.key)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SwitchButton extends ConsumerStatefulWidget {
  const _SwitchButton({required this.tenant});

  final Tenant tenant;

  @override
  ConsumerState<_SwitchButton> createState() => _SwitchButtonState();
}

class _SwitchButtonState extends ConsumerState<_SwitchButton> {
  var _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final access = ref.watch(tenantAccessProvider(widget.tenant.key));
    return switch (access) {
      TenantAccess.current => TixBadge(
        l10n.tenantCurrent,
        tone: TixTone.accent,
        key: const Key('tenant.switch'),
      ),
      TenantAccess.pinned => Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          TixButton(
            key: const Key('tenant.switch'),
            label: l10n.tenantSwitch,
            icon: Icons.swap_horiz,
            onPressed: null,
          ),
          InfoTip(l10n.tenantSwitchPinned),
        ],
      ),
      TenantAccess.member || TenantAccess.join => TixButton(
        key: const Key('tenant.switch'),
        label: access == TenantAccess.join
            ? l10n.tenantJoinSwitch
            : l10n.tenantSwitch,
        icon: Icons.swap_horiz,
        busy: _busy,
        onPressed: () => _switch(access == TenantAccess.join),
      ),
    };
  }

  Future<void> _switch(bool join) async {
    final l10n = context.l10n;
    if (join) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.tenantJoinSwitch),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TixMeasure.text),
            child: Text(l10n.tenantJoinBody(widget.tenant.name)),
          ),
          actions: [
            TixButton.quiet(
              label: l10n.cancel,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TixButton.primary(
              key: const Key('tenant.joinConfirm'),
              label: l10n.tenantJoinConfirm,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
      if (!(ok ?? false) || !mounted) return;
    }
    setState(() => _busy = true);
    final router = GoRouter.of(context);
    try {
      await ref
          .read(tenantDirectoryProvider.notifier)
          .switchTo(widget.tenant.key, join: join);
    } on Object catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
      return;
    }
    router.go(Routes.projects);
  }
}

class _Domains extends ConsumerWidget {
  const _Domains({required this.tenantKey});

  final String tenantKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final value = ref.watch(tenantDomainsProvider(tenantKey));
    return TixSection(
      title: l10n.domainsTitle,
      info: l10n.domainSharedInfo,
      children: [
        value.when(
          loading: () => const SkeletonList(rows: 2, inline: true),
          error: (e, _) => ErrorState(
            error: e,
            compact: true,
            onRetry: () => ref.invalidate(tenantDomainsProvider(tenantKey)),
          ),
          data: (domains) => domains.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(TixSpace.s4),
                  child: Text(l10n.tenantDomainsEmpty),
                )
              : Column(
                  children: [
                    for (final d in domains)
                      DomainRow(
                        domain: d,
                        trailing: Semantics(
                          label: l10n.domainShared,
                          child: Switch(
                            key: Key('domain.shared.${d.hostname}'),
                            value: d.shared,
                            onChanged: (v) => _share(context, ref, d, v),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _share(
    BuildContext context,
    WidgetRef ref,
    Domain d,
    bool shared,
  ) async {
    final l10n = context.l10n;
    try {
      await ref
          .read(tenantDomainsProvider(tenantKey).notifier)
          .setShared(d.hostname, shared: shared);
    } on Object catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }
}

class _Danger extends ConsumerWidget {
  const _Danger({required this.tenant});

  final Tenant tenant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current =
        ref.watch(tenantAccessProvider(tenant.key)) == TenantAccess.current;
    return TixSection(
      title: l10n.manageDangerZone,
      danger: true,
      children: [
        ListTile(
          title: Text(l10n.tenantDelete),
          subtitle: Text(
            current ? l10n.tenantDeleteCurrent : l10n.tenantDeleteHelp,
          ),
          trailing: TixButton.danger(
            key: const Key('tenant.delete'),
            label: l10n.manageDelete,
            size: TixButtonSize.small,
            onPressed: current ? null : () => _delete(context, ref),
          ),
        ),
      ],
    );
  }

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
      await ref.read(tenantDirectoryProvider.notifier).delete(tenant.key);
    } on Object catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
      return;
    }
    if (!context.mounted) return;
    showTixToast(context, l10n.tenantDeleted(tenant.name));
    context.go(Routes.manageTenants);
  }
}
