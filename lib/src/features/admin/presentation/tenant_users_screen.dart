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
import 'package:tix_mobile/src/core/widgets/paged_list_view.dart';
import 'package:tix_mobile/src/features/admin/application/global_admin.dart';
import 'package:tix_mobile/src/features/admin/application/tenant_admin.dart';

/// The users of any tenant, for a global admin: create one, add an
/// existing account, change or delete one, read their account log, and in
/// the active tenant clear a lost second factor.
class TenantUsersScreen extends ConsumerWidget {
  /// The users of [tenantKey].
  const TenantUsersScreen({required this.tenantKey, super.key});

  /// The tenant's key.
  final String tenantKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tenant = ref.watch(tenantSettingsProvider(tenantKey)).value;
    final name = tenant == null || tenant.name.isEmpty
        ? tenantKey
        : tenant.name;
    final create = TixAction(
      key: const Key('users.create'),
      label: l10n.adminUserCreate,
      icon: Icons.add,
      onPressed: () => _open(context, _UserForm(tenantKey: tenantKey)),
    );
    return TixPage(
      title: l10n.tenantUsersTitle,
      subtitle: name,
      primaryAction: create,
      actions: [
        TixIconButton(
          key: const Key('users.addMember'),
          icon: Icons.person_add_alt,
          tooltip: l10n.adminMemberAdd,
          onPressed: () => _open(context, _MemberForm(tenantKey: tenantKey)),
        ),
      ],
      body: AsyncBody(
        value: ref.watch(tenantUsersProvider(tenantKey)),
        onRetry: () => ref.invalidate(tenantUsersProvider(tenantKey)),
        data: (paged) => PagedListView(
          paged: paged,
          padding: const EdgeInsets.only(bottom: TixSpace.s7 * 2),
          empty: EmptyState(
            icon: Icons.people_outline,
            title: l10n.adminUsersEmpty,
            body: l10n.adminUsersEmptyBody,
            action: create,
          ),
          onRefresh: () => ref.refresh(tenantUsersProvider(tenantKey).future),
          onLoadMore: () =>
              ref.read(tenantUsersProvider(tenantKey).notifier).loadMore(),
          itemBuilder: (context, u) => _UserRow(tenantKey: tenantKey, user: u),
        ),
      ),
    );
  }
}

Future<void> _open(BuildContext context, Widget form) async {
  final done = await showTixSheet<Object>(context, builder: (_) => form);
  if (done != null && done != false && context.mounted) {
    showTixToast(context, context.l10n.tenantSaved);
  }
}

String _roleLabel(AppLocalizations l10n, Role? role) => switch (role) {
  Role.admin => l10n.adminRoleAdmin,
  Role.member => l10n.adminRoleMember,
  Role.viewer => l10n.adminRoleViewer,
  null => l10n.adminRoleNone,
};

enum _UserAction { edit, log, clearTotp, delete }

class _UserRow extends ConsumerWidget {
  const _UserRow({required this.tenantKey, required this.user});

  final String tenantKey;
  final TenantUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final name = user.displayName.isEmpty ? user.email : user.displayName;
    return ListTile(
      key: Key('user.${user.id}'),
      leading: TixAvatar(label: name, seed: user.email, hued: true),
      title: Text(name),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: TixSpace.s1),
        child: Wrap(
          spacing: TixSpace.s2,
          runSpacing: TixSpace.s1,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (user.displayName.isNotEmpty) Text(user.email),
            TixBadge(_roleLabel(l10n, user.role)),
            if (user.globalAdmin)
              TixBadge(l10n.globalAdminBadge, tone: TixTone.accent),
            if (user.disabledAt != null)
              TixBadge(l10n.adminUserDisabled, tone: TixTone.danger),
            if (user.totpEnrolled)
              TixBadge(l10n.adminUserTotp, tone: TixTone.ok),
            if (user.requirePasswordChange)
              TixBadge(l10n.adminUserMustChangePassword, tone: TixTone.warn),
          ],
        ),
      ),
      trailing: TixIconButton(
        key: Key('user.menu.${user.id}'),
        icon: Icons.more_horiz,
        tooltip: l10n.adminUserActions,
        onPressed: () => _menu(context, ref),
      ),
      onTap: () => _menu(context, ref),
    );
  }

  Future<void> _menu(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final own =
        ref.read(tenantAccessProvider(tenantKey)) == TenantAccess.current;
    final choice = await showActionSheet<_UserAction>(
      context,
      title: user.email,
      actions: [
        TixSheetAction(
          key: const Key('user.edit'),
          value: _UserAction.edit,
          label: l10n.adminUserEdit,
          icon: Icons.edit_outlined,
        ),
        TixSheetAction(
          key: const Key('user.log'),
          value: _UserAction.log,
          label: l10n.adminAccountLogTitle,
          icon: Icons.history,
        ),
        if (own && user.totpEnrolled)
          TixSheetAction(
            key: const Key('user.clearTotp'),
            value: _UserAction.clearTotp,
            label: l10n.adminUserClearTotp,
            icon: Icons.phonelink_erase,
            destructive: true,
          ),
        TixSheetAction(
          key: const Key('user.delete'),
          value: _UserAction.delete,
          label: l10n.adminUserDelete,
          icon: Icons.delete_outline,
          destructive: true,
        ),
      ],
    );
    if (!context.mounted) return;
    final users = ref.read(tenantUsersProvider(tenantKey).notifier);
    switch (choice) {
      case _UserAction.edit:
        await _open(context, _EditForm(tenantKey: tenantKey, user: user));
      case _UserAction.log:
        await context.push(Routes.accountLog(user.email));
      case _UserAction.clearTotp:
        await _confirmed(
          context,
          title: l10n.adminUserClearTotp,
          body: l10n.adminUserClearTotpBody(user.email),
          action: l10n.adminUserClearTotpConfirm,
          run: () => users.clearSecondFactor(user.id),
        );
      case _UserAction.delete:
        await _confirmed(
          context,
          title: l10n.adminUserDelete,
          body: l10n.adminUserDeleteBody(user.email),
          action: l10n.manageDelete,
          run: () => users.delete(user.id),
        );
      case null:
        return;
    }
  }

  Future<void> _confirmed(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
    required Future<void> Function() run,
  }) async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: title,
      body: body,
      action: action,
    );
    if (!ok || !context.mounted) return;
    try {
      await run();
      if (context.mounted) showTixToast(context, l10n.tenantSaved);
    } on Object catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }
}

class _RolePicker extends StatelessWidget {
  const _RolePicker({required this.role, required this.onChanged});

  final Role role;
  final ValueChanged<Role> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.adminUserRole, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: TixSpace.s2),
        SegmentedButton<Role>(
          key: const Key('user.role'),
          showSelectedIcon: false,
          segments: [
            for (final r in Role.values)
              ButtonSegment(value: r, label: Text(_roleLabel(l10n, r))),
          ],
          selected: {role},
          onSelectionChanged: (s) => onChanged(s.first),
        ),
      ],
    );
  }
}

class _UserForm extends ConsumerStatefulWidget {
  const _UserForm({required this.tenantKey});

  final String tenantKey;

  @override
  ConsumerState<_UserForm> createState() => _UserFormState();
}

class _UserFormState extends ConsumerState<_UserForm> {
  final _email = TextEditingController();
  final _handle = TextEditingController();
  final _display = TextEditingController();
  final _password = TextEditingController();
  Role _role = Role.member;
  var _mustChange = true;

  @override
  void dispose() {
    for (final c in [_email, _handle, _display, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String? opt(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    final password = _password.text;
    return FormSheet(
      title: l10n.adminUserCreate,
      submitLabel: l10n.adminUserCreateSubmit,
      onSubmit: () => ref
          .read(tenantUsersProvider(widget.tenantKey).notifier)
          .create(
            CreateUserInput(
              email: _email.text.trim(),
              handle: opt(_handle),
              displayName: opt(_display),
              role: _role,
              password: password.isEmpty ? null : password,
              requirePasswordChange: password.isEmpty ? null : _mustChange,
            ),
          ),
      children: [
        TixTextField(
          fieldKey: const Key('user.email'),
          label: l10n.adminUserEmail,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        formGap,
        TixTextField(
          fieldKey: const Key('user.handle'),
          label: l10n.adminUserHandle,
          help: l10n.adminUserHandleHelp,
          controller: _handle,
        ),
        formGap,
        TixTextField(
          fieldKey: const Key('user.display'),
          label: l10n.adminUserDisplayName,
          controller: _display,
        ),
        formGap,
        _RolePicker(role: _role, onChanged: (r) => setState(() => _role = r)),
        formGap,
        TixTextField(
          fieldKey: const Key('user.password'),
          label: l10n.adminUserPassword,
          help: l10n.adminUserPasswordHelp,
          controller: _password,
          obscure: true,
          onChanged: (_) => setState(() {}),
        ),
        if (password.isNotEmpty)
          TixSwitchRow(
            key: const Key('user.mustChange'),
            title: l10n.adminUserMustChangeSwitch,
            value: _mustChange,
            onChanged: (v) => setState(() => _mustChange = v),
          ),
      ],
    );
  }
}

class _MemberForm extends ConsumerStatefulWidget {
  const _MemberForm({required this.tenantKey});

  final String tenantKey;

  @override
  ConsumerState<_MemberForm> createState() => _MemberFormState();
}

class _MemberFormState extends ConsumerState<_MemberForm> {
  final _email = TextEditingController();
  final _handle = TextEditingController();
  Role _role = Role.member;

  @override
  void dispose() {
    _email.dispose();
    _handle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FormSheet(
      title: l10n.adminMemberAdd,
      submitLabel: l10n.adminMemberAddSubmit,
      onSubmit: () => ref
          .read(tenantUsersProvider(widget.tenantKey).notifier)
          .addMember(
            AddTenantMemberInput(
              email: _email.text.trim(),
              handle: _handle.text.trim().isEmpty ? null : _handle.text.trim(),
              role: _role,
            ),
          ),
      children: [
        Text(
          l10n.adminMemberAddHelp,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        formGap,
        TixTextField(
          fieldKey: const Key('member.email'),
          label: l10n.adminUserEmail,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        formGap,
        TixTextField(
          fieldKey: const Key('member.handle'),
          label: l10n.adminUserHandle,
          help: l10n.adminUserHandleHelp,
          controller: _handle,
        ),
        formGap,
        _RolePicker(role: _role, onChanged: (r) => setState(() => _role = r)),
      ],
    );
  }
}

class _EditForm extends ConsumerStatefulWidget {
  const _EditForm({required this.tenantKey, required this.user});

  final String tenantKey;
  final TenantUser user;

  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  late final _display = TextEditingController(text: widget.user.displayName);
  final _password = TextEditingController();
  late Role _role = widget.user.role ?? Role.member;
  late bool _disabled = widget.user.disabledAt != null;
  late bool _mustChange = widget.user.requirePasswordChange;

  @override
  void dispose() {
    _display.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final u = widget.user;
    return FormSheet(
      title: l10n.adminUserEditTitle(u.email),
      submitLabel: l10n.manageSave,
      onSubmit: () {
        final display = _display.text.trim();
        return ref
            .read(tenantUsersProvider(widget.tenantKey).notifier)
            .edit(
              u.id,
              UpdateUserInput(
                displayName: display == u.displayName ? null : display,
                role: _role == u.role ? null : _role,
                disabled: _disabled == (u.disabledAt != null)
                    ? null
                    : _disabled,
                requirePasswordChange: _mustChange == u.requirePasswordChange
                    ? null
                    : _mustChange,
                password: _password.text.isEmpty ? null : _password.text,
              ),
            );
      },
      children: [
        TixTextField(
          fieldKey: const Key('user.display'),
          label: l10n.adminUserDisplayName,
          controller: _display,
        ),
        formGap,
        _RolePicker(role: _role, onChanged: (r) => setState(() => _role = r)),
        formGap,
        TixSwitchRow(
          key: const Key('user.disabled'),
          title: l10n.adminUserDisabledSwitch,
          subtitle: l10n.adminUserDisabledHelp,
          value: _disabled,
          onChanged: (v) => setState(() => _disabled = v),
        ),
        TixSwitchRow(
          key: const Key('user.mustChange'),
          title: l10n.adminUserMustChangeSwitch,
          value: _mustChange,
          onChanged: (v) => setState(() => _mustChange = v),
        ),
        formGap,
        TixTextField(
          fieldKey: const Key('user.password'),
          label: l10n.adminUserNewPassword,
          help: l10n.adminUserNewPasswordHelp,
          controller: _password,
          obscure: true,
        ),
      ],
    );
  }
}
