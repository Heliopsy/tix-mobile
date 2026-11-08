// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/admin.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/core/widgets/form_sheet.dart';
import 'package:tix_mobile/src/features/admin/application/global_admin.dart';

/// The global admins of the installation: grant it to an account by
/// email, or take it away.
class GlobalAdminsScreen extends ConsumerWidget {
  /// Creates the screen.
  const GlobalAdminsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final grant = TixAction(
      key: const Key('globalAdmins.grant'),
      label: l10n.globalAdminGrant,
      icon: Icons.add,
      onPressed: () => _grant(context),
    );
    return TixPage(
      title: l10n.globalAdminsTitle,
      subtitle: l10n.globalAdminsSubtitle,
      primaryAction: grant,
      body: AsyncBody(
        value: ref.watch(globalAdminsProvider),
        onRetry: () => ref.invalidate(globalAdminsProvider),
        data: (admins) => RefreshIndicator(
          onRefresh: () => ref.refresh(globalAdminsProvider.future),
          child: ListView(
            padding: const EdgeInsets.only(bottom: TixSpace.s7 * 2),
            children: [
              if (admins.isEmpty)
                EmptyState(
                  icon: Icons.admin_panel_settings_outlined,
                  title: l10n.globalAdminsEmpty,
                  body: l10n.globalAdminsSubtitle,
                  action: grant,
                )
              else
                for (final u in admins) _AdminRow(user: u),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _grant(BuildContext context) async {
    final done = await showTixSheet<Object>(
      context,
      builder: (_) => const _GrantForm(),
    );
    if (done != null && done != false && context.mounted) {
      showTixToast(context, context.l10n.globalAdminGranted);
    }
  }
}

class _AdminRow extends ConsumerWidget {
  const _AdminRow({required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final name = user.displayName.isEmpty ? user.email : user.displayName;
    return ListTile(
      key: Key('globalAdmin.${user.email}'),
      leading: TixAvatar(label: name, seed: user.email, hued: true),
      title: Text(name),
      subtitle: user.displayName.isEmpty ? null : Text(user.email),
      onTap: () => context.push(Routes.accountLog(user.email)),
      trailing: TixButton.danger(
        key: Key('globalAdmin.revoke.${user.email}'),
        label: l10n.globalAdminRevoke,
        size: TixButtonSize.small,
        onPressed: () => _revoke(context, ref),
      ),
    );
  }

  Future<void> _revoke(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.globalAdminRevoke,
      body: l10n.globalAdminRevokeBody(user.email),
      action: l10n.globalAdminRevoke,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(globalAdminsProvider.notifier).revoke(user.email);
      if (context.mounted) showTixToast(context, l10n.globalAdminRevoked);
    } on Object catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }
}

class _GrantForm extends ConsumerStatefulWidget {
  const _GrantForm();

  @override
  ConsumerState<_GrantForm> createState() => _GrantFormState();
}

class _GrantFormState extends ConsumerState<_GrantForm> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FormSheet(
      title: l10n.globalAdminGrant,
      submitLabel: l10n.globalAdminGrantSubmit,
      onSubmit: () =>
          ref.read(globalAdminsProvider.notifier).grant(_email.text.trim()),
      children: [
        Text(
          l10n.globalAdminGrantHelp,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        formGap,
        TixTextField(
          fieldKey: const Key('globalAdmin.email'),
          label: l10n.adminUserEmail,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }
}
