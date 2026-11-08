// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/admin.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/core/widgets/form_sheet.dart';
import 'package:tix_mobile/src/core/widgets/paged_list_view.dart';
import 'package:tix_mobile/src/features/admin/application/global_admin.dart';
import 'package:tix_mobile/src/features/admin/presentation/tenant_detail.dart';

/// Every tenant on the server, for a global admin: create one with its
/// first admin, open one, switch into it. On a wide window the chosen
/// tenant sits beside the list.
class TenantsScreen extends ConsumerWidget {
  /// The list, with [selectedKey] open beside it on a wide window.
  const TenantsScreen({this.selectedKey, super.key});

  /// The tenant open in the detail pane.
  final String? selectedKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final create = TixAction(
      key: const Key('tenants.create'),
      label: l10n.tenantCreate,
      icon: Icons.add,
      onPressed: () => createTenant(context),
    );
    final list = AsyncBody(
      value: ref.watch(tenantDirectoryProvider),
      onRetry: () => ref.invalidate(tenantDirectoryProvider),
      data: (paged) => PagedListView(
        paged: paged,
        empty: EmptyState(
          icon: Icons.domain,
          title: l10n.tenantsEmpty,
          body: l10n.tenantsEmptyBody,
          action: create,
        ),
        onRefresh: () => ref.refresh(tenantDirectoryProvider.future),
        onLoadMore: () => ref.read(tenantDirectoryProvider.notifier).loadMore(),
        itemBuilder: (context, t) =>
            _TenantRow(tenant: t, selected: t.key == selectedKey),
      ),
    );
    final key = selectedKey;
    return TixPage(
      title: l10n.tenantsTitle,
      subtitle: l10n.tenantsSubtitle,
      primaryAction: create,
      actions: [
        TixIconButton(
          key: const Key('tenants.globalAdmins'),
          icon: Icons.admin_panel_settings_outlined,
          tooltip: l10n.globalAdminsTitle,
          onPressed: () => context.go(Routes.manageGlobalAdmins),
        ),
      ],
      body: !context.isTwoPane
          ? list
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 400, child: list),
                VerticalDivider(width: 1, color: context.tix.line),
                Expanded(
                  child: key == null
                      ? Center(
                          child: Text(
                            l10n.tenantsPick,
                            style: TextStyle(color: context.tix.muted),
                          ),
                        )
                      : TenantDetail(key: ValueKey(key), tenantKey: key),
                ),
              ],
            ),
    );
  }
}

/// Opens the form that creates a tenant, then shows any password the
/// server generated, once.
Future<void> createTenant(BuildContext context) async {
  final created = await showTixSheet<Object>(
    context,
    builder: (_) => const _CreateTenantForm(),
  );
  if (created is! CreatedTenant || !context.mounted) return;
  final l10n = context.l10n;
  if (created.initialCredentials.isEmpty) {
    showTixToast(context, l10n.tenantCreated(created.name));
    return;
  }
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(l10n.tenantCreated(created.name)),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: TixMeasure.text),
        child: SingleChildScrollView(
          child: OneTimeSecret(
            key: const Key('tenant.credentials'),
            heading: l10n.tenantCredentialsHeading,
            note: l10n.tenantCredentialsNote,
            values: [
              for (final c in created.initialCredentials)
                '${c.email}  ${c.password}',
            ],
          ),
        ),
      ),
      actions: [
        TixButton.primary(
          key: const Key('tenant.credentialsDone'),
          label: l10n.totpCodesSaved,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

class _TenantRow extends ConsumerWidget {
  const _TenantRow({required this.tenant, required this.selected});

  final Tenant tenant;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final access = ref.watch(tenantAccessProvider(tenant.key));
    final accent = TixAccent.resolve(tenant.theme);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final totp =
        tenant.requireTotpWeb || tenant.requireTotpCli || tenant.requireTotpSsh;
    return Material(
      color: selected ? t.accentSoft : Colors.transparent,
      child: ListTile(
        key: Key('tenant.${tenant.key}'),
        selected: selected,
        leading: CircleAvatar(
          radius: 10,
          backgroundColor: dark ? accent.accentDark : accent.accent,
        ),
        title: Text(tenant.name.isEmpty ? tenant.key : tenant.name),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: TixSpace.s1),
          child: Wrap(
            spacing: TixSpace.s2,
            runSpacing: TixSpace.s1,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(tenant.key, style: tixMono(context)),
              if (access == TenantAccess.current)
                TixBadge(l10n.tenantCurrent, tone: TixTone.accent),
              if (access == TenantAccess.member) TixBadge(l10n.tenantMember),
              if (totp) TixBadge(l10n.tenantTotpBadge),
              if (tenant.trashOff) TixBadge(l10n.tenantNoTrash),
            ],
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: t.lineStrong),
        onTap: () => context.go(Routes.manageTenantDetail(tenant.key)),
      ),
    );
  }
}

class _CreateTenantForm extends ConsumerStatefulWidget {
  const _CreateTenantForm();

  @override
  ConsumerState<_CreateTenantForm> createState() => _CreateTenantFormState();
}

class _CreateTenantFormState extends ConsumerState<_CreateTenantForm> {
  final _key = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _display = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    for (final c in [_key, _name, _email, _display, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String? opt(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    return FormSheet(
      title: l10n.tenantCreate,
      submitLabel: l10n.tenantCreateSubmit,
      onSubmit: () => ref
          .read(tenantDirectoryProvider.notifier)
          .create(
            CreateTenantInput(
              key: _key.text.trim(),
              name: _name.text.trim(),
              admins: _email.text.trim().isEmpty
                  ? null
                  : [
                      TenantAdminInput(
                        email: _email.text.trim(),
                        displayName: opt(_display),
                        password: _password.text.isEmpty
                            ? null
                            : _password.text,
                      ),
                    ],
            ),
          ),
      children: [
        TixTextField(
          fieldKey: const Key('tenant.create.key'),
          label: l10n.tenantKey,
          hint: 'acme',
          help: l10n.tenantKeyHelp,
          controller: _key,
        ),
        formGap,
        TixTextField(
          fieldKey: const Key('tenant.create.name'),
          label: l10n.tenantName,
          hint: 'Acme',
          controller: _name,
        ),
        formGap,
        SectionHeader(
          title: l10n.tenantFirstAdmin,
          subtitle: l10n.tenantFirstAdminHelp,
          padding: EdgeInsets.zero,
        ),
        formGap,
        TixTextField(
          fieldKey: const Key('tenant.create.email'),
          label: l10n.adminUserEmail,
          hint: 'ada@example.com',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        formGap,
        TixTextField(
          fieldKey: const Key('tenant.create.display'),
          label: l10n.adminUserDisplayName,
          controller: _display,
        ),
        formGap,
        TixTextField(
          fieldKey: const Key('tenant.create.password'),
          label: l10n.adminUserPassword,
          help: l10n.tenantPasswordHelp,
          controller: _password,
          obscure: true,
        ),
      ],
    );
  }
}
