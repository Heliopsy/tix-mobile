// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/l10n/dates.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/session/people.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/data/repositories/people_repository.dart';
import 'package:tix_mobile/src/features/people/application/people.dart';
import 'package:tix_mobile/src/features/people/presentation/people_sheets.dart';
import 'package:tix_mobile/src/features/people/presentation/users_screen.dart';

/// One account: its details, its role and state, and the ways to end it.
class UserScreen extends ConsumerWidget {
  /// Shows the account [userId].
  const UserScreen({required this.userId, super.key});

  /// The account's actor id.
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final users = ref.watch(usersProvider);
    final view = users.value;
    final person = view?.people.items
        .where((p) => p.user.id == userId)
        .firstOrNull;
    if (view != null && person == null) {
      return TixPage(
        title: l10n.peopleTitle,
        body: ErrorState(
          error: const TixException(TixErrorKind.notFound),
          onRetry: () => ref.invalidate(usersProvider),
          onBack: () => context.pop(),
        ),
      );
    }
    return TixPage(
      title: person?.label ?? l10n.peopleTitle,
      subtitle: person?.user.email,
      body: AsyncBody(
        value: users,
        onRetry: () => ref.invalidate(usersProvider),
        data: (view) => _Details(person: person!, rolesKnown: view.rolesKnown),
      ),
    );
  }
}

class _Details extends ConsumerWidget {
  const _Details({required this.person, required this.rolesKnown});

  final Person person;
  final bool rolesKnown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final access = ref.watch(currentAccessProvider).value;
    final self = person.user.id == access?.me.id;
    final user = person.user;
    final role = person.role;
    final created = user.createdAt;
    final tenantAdmin = access?.can(Scopes.tenantAdmin) ?? false;
    return ListView(
      padding: const EdgeInsets.only(bottom: TixSpace.s7),
      children: [
        Padding(
          padding: const EdgeInsets.all(TixSpace.s4),
          child: TixPropertyList(
            children: [
              TixPropertyRow(
                key: const Key('user.name'),
                label: l10n.peopleDisplayName,
                editLabel: l10n.peopleRename,
                onTap: () => _rename(context, ref),
                child: Text(
                  user.displayName.isEmpty
                      ? l10n.peopleNoName
                      : user.displayName,
                ),
              ),
              TixPropertyRow(
                key: const Key('user.role'),
                label: l10n.peopleRole,
                editLabel: l10n.peopleChangeRole,
                onTap: rolesKnown ? () => _changeRole(context, ref) : null,
                child: Text(
                  role == null ? l10n.peopleNoRole : roleLabel(l10n, role),
                ),
              ),
              TixPropertyRow(
                label: l10n.emailLabel,
                child: SelectableText(user.email, style: tixMono(context)),
              ),
              TixPropertyRow(
                label: l10n.peopleSignIn,
                child: Text(
                  user.ssoProvider.isNotEmpty
                      ? l10n.peopleSso(user.ssoProvider)
                      : l10n.peoplePasswordSignIn,
                ),
              ),
              TixPropertyRow(
                label: l10n.peopleSecondFactor,
                child: Text(
                  user.totpEnrolled ? l10n.peopleTotpOn : l10n.peopleTotpOff,
                ),
              ),
              if (created != null)
                TixPropertyRow(
                  label: l10n.peopleCreatedAt,
                  child: Text(formatDay(context, created)),
                ),
            ],
          ),
        ),
        TixSection(
          title: l10n.peopleAccess,
          children: [
            if (!self)
              TixSwitchRow(
                key: const Key('user.disabled'),
                title: l10n.peopleDisabledSwitch,
                subtitle: l10n.peopleDisabledHelp,
                value: person.disabled,
                onChanged: (v) => _update(
                  context,
                  ref,
                  UpdateUserInput(disabled: v),
                  v
                      ? l10n.peopleDisabledToast(person.label)
                      : l10n.peopleEnabledToast(person.label),
                ),
              ),
            TixSwitchRow(
              key: const Key('user.requireChange'),
              title: l10n.peopleRequireChange,
              subtitle: l10n.peopleRequireChangeHelp,
              value: user.requirePasswordChange,
              onChanged: (v) => _update(
                context,
                ref,
                UpdateUserInput(requirePasswordChange: v),
                l10n.peopleSaved,
              ),
            ),
          ],
        ),
        if (!self)
          TixSection(
            title: l10n.peopleDangerZone,
            danger: true,
            children: [
              if (tenantAdmin && role != null)
                ListTile(
                  title: Text(l10n.peopleRemoveMember),
                  subtitle: Text(l10n.peopleRemoveMemberHelp),
                  trailing: TixButton.danger(
                    key: const Key('user.removeMember'),
                    label: l10n.peopleRemoveMemberButton,
                    size: TixButtonSize.small,
                    onPressed: () => _removeMember(context, ref),
                  ),
                ),
              ListTile(
                title: Text(l10n.peopleDelete(person.label)),
                subtitle: Text(l10n.peopleDeleteHelp),
                trailing: TixButton.danger(
                  key: const Key('user.delete'),
                  label: l10n.peopleDeleteButton,
                  icon: Icons.delete_outline,
                  size: TixButtonSize.small,
                  onPressed: () => _delete(context, ref),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _update(
    BuildContext context,
    WidgetRef ref,
    UpdateUserInput change,
    String done,
  ) async {
    final l10n = context.l10n;
    try {
      await ref.read(usersProvider.notifier).change(person, change);
      if (context.mounted) showTixToast(context, done);
    } on TixException catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final name = await showTixSheet<String>(
      context,
      builder: (_) => _RenameSheet(initial: person.user.displayName),
    );
    if (name == null || !context.mounted) return;
    await _update(
      context,
      ref,
      UpdateUserInput(displayName: name.trim()),
      l10n.peopleSaved,
    );
  }

  Future<void> _changeRole(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final role = await showTixSheet<Role>(
      context,
      builder: (_) => _RoleSheet(initial: person.role ?? Role.member),
    );
    if (role == null || role == person.role || !context.mounted) return;
    await _update(
      context,
      ref,
      UpdateUserInput(role: role),
      l10n.peopleRoleChanged(person.label, roleLabel(l10n, role)),
    );
  }

  Future<void> _removeMember(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.peopleRemoveMemberTitle(person.label),
      body: l10n.peopleRemoveMemberBody,
      action: l10n.peopleRemoveMemberButton,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(usersProvider.notifier).removeMember(person);
      if (context.mounted) {
        showTixToast(context, l10n.peopleMemberRemoved(person.label));
      }
    } on TixException catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.peopleDeleteTitle(person.label),
      body: l10n.peopleDeleteBody,
      action: l10n.peopleDelete(person.label),
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(usersProvider.notifier).delete(person);
      if (!context.mounted) return;
      showTixToast(context, l10n.peopleDeleted(person.label));
      if (context.canPop()) context.pop();
    } on TixException catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }
}

class _RenameSheet extends StatefulWidget {
  const _RenameSheet({required this.initial});

  final String initial;

  @override
  State<_RenameSheet> createState() => _RenameSheetState();
}

class _RenameSheetState extends State<_RenameSheet> {
  late final _name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TixSheetBody(
      title: l10n.peopleRename,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('rename.save'),
          label: l10n.peopleSave,
          onPressed: () => Navigator.of(context).pop(_name.text),
        ),
      ],
      child: TixTextField(
        label: l10n.peopleDisplayName,
        controller: _name,
        fieldKey: const Key('rename.field'),
        autofocus: true,
        help: l10n.peopleDisplayNameHelp,
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
    );
  }
}

class _RoleSheet extends StatefulWidget {
  const _RoleSheet({required this.initial});

  final Role initial;

  @override
  State<_RoleSheet> createState() => _RoleSheetState();
}

class _RoleSheetState extends State<_RoleSheet> {
  late Role _role = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TixSheetBody(
      title: l10n.peopleChangeRole,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('role.save'),
          label: l10n.peopleSave,
          onPressed: () => Navigator.of(context).pop(_role),
        ),
      ],
      child: RolePicker(
        value: _role,
        onChanged: (r) => setState(() => _role = r),
      ),
    );
  }
}
