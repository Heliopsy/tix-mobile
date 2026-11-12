// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/config/server_url.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/l10n/dates.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/sharing.dart';
import 'package:tix_mobile/src/core/session/people.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/repositories/people_repository.dart';
import 'package:tix_mobile/src/features/people/application/people.dart';

/// Opens the form that creates an account, with a password or an invite
/// link. An invite's link is shown once afterwards.
Future<void> showCreateUserSheet(BuildContext context) async {
  final issued = await showTixSheet<IssuedInvite>(
    context,
    builder: (_) => const CreateUserSheet(),
  );
  if (issued != null && context.mounted) {
    await showInviteLinkSheet(context, issued);
  }
}

/// How a new account signs in.
enum SignInMode {
  /// A password the admin types.
  password,

  /// A link the person sets their own password with.
  invite,
}

/// The create-a-user form.
class CreateUserSheet extends ConsumerStatefulWidget {
  /// Creates the form.
  const CreateUserSheet({super.key});

  @override
  ConsumerState<CreateUserSheet> createState() => _CreateUserSheetState();
}

class _CreateUserSheetState extends ConsumerState<CreateUserSheet> {
  final _email = TextEditingController();
  final _name = TextEditingController();
  final _password = TextEditingController();
  SignInMode _mode = SignInMode.invite;
  Role _role = Role.member;
  var _requireChange = true;
  String _expiry = defaultInviteExpiry;
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _name.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_mode == SignInMode.invite) {
        final issued = await ref
            .read(invitesProvider.notifier)
            .invite(
              email: _email.text,
              role: _role,
              expiresIn: _expiry,
              displayName: _name.text,
            );
        if (mounted) Navigator.of(context).pop(issued);
      } else {
        await ref
            .read(usersProvider.notifier)
            .create(
              email: _email.text,
              password: _password.text,
              role: _role,
              displayName: _name.text,
              requirePasswordChange: _requireChange,
            );
        if (!mounted) return;
        final l10n = context.l10n;
        final email = _email.text.trim();
        Navigator.of(context).pop();
        showTixToast(context, l10n.peopleCreated(email));
      }
    } on TixException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = errorMessage(context.l10n, e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final invite = _mode == SignInMode.invite;
    return TixSheetBody(
      title: l10n.peopleAdd,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('people.create'),
          label: invite ? l10n.peopleCreateInvite : l10n.peopleCreateUser,
          busy: _busy,
          onPressed: _submit,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.peopleSignInMode,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              InfoTip(l10n.peopleSignInModeInfo, size: 32),
            ],
          ),
          const SizedBox(height: TixSpace.s2),
          SegmentedButton<SignInMode>(
            key: const Key('people.mode'),
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: SignInMode.invite,
                label: Text(l10n.peopleModeInvite),
                icon: const Icon(Icons.link),
              ),
              ButtonSegment(
                value: SignInMode.password,
                label: Text(l10n.peopleModePassword),
                icon: const Icon(Icons.password),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() => _mode = s.first),
          ),
          const SizedBox(height: TixSpace.s4),
          TixTextField(
            label: l10n.emailLabel,
            controller: _email,
            fieldKey: const Key('people.email'),
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
          ),
          const SizedBox(height: TixSpace.s3),
          TixTextField(
            label: l10n.peopleDisplayName,
            controller: _name,
            fieldKey: const Key('people.name'),
            help: l10n.peopleDisplayNameHelp,
          ),
          const SizedBox(height: TixSpace.s3),
          RolePicker(value: _role, onChanged: (r) => setState(() => _role = r)),
          const SizedBox(height: TixSpace.s3),
          if (invite) ...[
            Text(
              l10n.peopleLinkExpires,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: TixSpace.s2),
            Wrap(
              spacing: TixSpace.s2,
              runSpacing: TixSpace.s2,
              children: [
                for (final e in inviteExpiries)
                  ChoiceChip(
                    key: Key('people.expiry.${e.key}'),
                    label: Text(l10n.peopleDays(e.days)),
                    selected: _expiry == e.key,
                    onSelected: (_) => setState(() => _expiry = e.key),
                  ),
              ],
            ),
            const SizedBox(height: TixSpace.s2),
            Text(
              l10n.peopleInviteHelp,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ] else ...[
            TixTextField(
              label: l10n.passwordLabel,
              controller: _password,
              fieldKey: const Key('people.password'),
              obscure: true,
              autofillHints: const [AutofillHints.newPassword],
            ),
            TixSwitchRow(
              key: const Key('people.requireChange'),
              title: l10n.peopleRequireChangeFirst,
              value: _requireChange,
              onChanged: (v) => setState(() => _requireChange = v),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: TixSpace.s3),
            Text(_error!, style: TextStyle(color: context.tix.danger)),
          ],
        ],
      ),
    );
  }
}

/// Chooses a role: viewer, member or admin, each with what it allows.
class RolePicker extends StatelessWidget {
  /// Shows [value], reporting a choice to [onChanged].
  const RolePicker({required this.value, required this.onChanged, super.key});

  /// The role chosen.
  final Role value;

  /// Called with the new role.
  final ValueChanged<Role> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.peopleRole, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: TixSpace.s2),
        SegmentedButton<Role>(
          key: const Key('people.role'),
          showSelectedIcon: false,
          segments: [
            for (final r in Role.values)
              ButtonSegment(value: r, label: Text(_label(l10n, r))),
          ],
          selected: {value},
          onSelectionChanged: (s) => onChanged(s.first),
        ),
        const SizedBox(height: TixSpace.s1),
        Text(switch (value) {
          Role.viewer => l10n.roleViewerHelp,
          Role.member => l10n.roleMemberHelp,
          Role.admin => l10n.roleAdminHelp,
        }, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  static String _label(AppLocalizations l10n, Role r) => switch (r) {
    Role.viewer => l10n.roleViewer,
    Role.member => l10n.roleMember,
    Role.admin => l10n.roleAdmin,
  };
}

/// Shows an invite's link once, with Copy and Share.
Future<void> showInviteLinkSheet(BuildContext context, IssuedInvite issued) =>
    showTixSheet<void>(
      context,
      dismissible: false,
      builder: (_) => InviteLinkSheet(issued: issued),
    );

/// An invite's link, shown once.
class InviteLinkSheet extends ConsumerWidget {
  /// Shows [issued]'s link.
  const InviteLinkSheet({required this.issued, super.key});

  /// The invite as issued, link and all.
  final IssuedInvite issued;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final base = ref.watch(sessionControllerProvider).value?.baseUrl ?? '';
    final link = absoluteLink(issued.url, issued.path, base);
    final expires = issued.expiresAt;
    final sharing = ref.read(textSharingProvider);
    return TixSheetBody(
      title: l10n.peopleInviteLink,
      actions: [
        Builder(
          builder: (context) => TixButton.quiet(
            key: const Key('secret.share'),
            label: l10n.secretShare,
            icon: Icons.ios_share,
            onPressed: () => sharing.share(link, origin: originOf(context)),
          ),
        ),
        TixButton.primary(
          key: const Key('secret.done'),
          label: l10n.secretDone,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      child: OneTimeSecret(
        heading: l10n.peopleSendLink(issued.email),
        note: expires == null
            ? l10n.peopleLinkOnce
            : l10n.peopleLinkOnceUntil(formatDay(context, expires)),
        values: [link],
      ),
    );
  }
}

/// [url] when the server knew its own address, else [path] on [base].
String absoluteLink(String url, String path, String base) {
  if (url.isNotEmpty) return url;
  return '${withoutTrailingSlash(base)}$path';
}

/// Opens the form that gives an existing actor a role here.
Future<void> showAddMemberSheet(BuildContext context) =>
    showTixSheet<void>(context, builder: (_) => const AddMemberSheet());

/// Gives an actor without a membership a role in this tenant.
class AddMemberSheet extends ConsumerStatefulWidget {
  /// Creates the form.
  const AddMemberSheet({super.key});

  @override
  ConsumerState<AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends ConsumerState<AddMemberSheet> {
  String? _actor;
  Role _role = Role.member;
  var _busy = false;
  String? _error;

  Future<void> _submit() async {
    final actor = _actor;
    if (actor == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(usersProvider.notifier).addMember(actor, _role);
      ref.invalidate(nonMembersProvider);
      if (mounted) Navigator.of(context).pop();
    } on TixException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = errorMessage(context.l10n, e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actors = ref.watch(nonMembersProvider);
    return TixSheetBody(
      title: l10n.peopleAddMember,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('member.add'),
          label: l10n.peopleAddMemberButton,
          busy: _busy,
          onPressed: _actor == null ? null : _submit,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.peopleAddMemberHelp,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: TixSpace.s3),
          switch (actors) {
            AsyncData(:final value) when value.isEmpty => Text(
              l10n.peopleNoActors,
            ),
            AsyncData(:final value) => RadioGroup<String>(
              groupValue: _actor,
              onChanged: (v) => setState(() => _actor = v),
              child: Column(
                children: [
                  for (final a in value)
                    RadioListTile<String>(
                      key: Key('member.actor.${a.id}'),
                      value: a.id,
                      title: Text(a.label),
                      subtitle: Text(
                        '@${a.handle} · '
                        '${_kind(l10n, a)}',
                      ),
                    ),
                ],
              ),
            ),
            AsyncError(:final error) => ErrorState(
              error: error,
              compact: true,
              onRetry: () => ref.invalidate(nonMembersProvider),
            ),
            _ => const SkeletonList(rows: 3, inline: true),
          },
          const SizedBox(height: TixSpace.s3),
          RolePicker(value: _role, onChanged: (r) => setState(() => _role = r)),
          if (_error != null) ...[
            const SizedBox(height: TixSpace.s3),
            Text(_error!, style: TextStyle(color: context.tix.danger)),
          ],
        ],
      ),
    );
  }
}

String _kind(AppLocalizations l10n, Actor a) =>
    a.kind == ActorKind.agent ? l10n.peopleAgent : l10n.peoplePerson;
