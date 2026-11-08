// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart';
import 'package:tix_mobile/src/core/session/admin.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/core/widgets/form_sheet.dart';
import 'package:tix_mobile/src/features/security/application/security.dart';

/// The signed-in person's own security: their second factor and the SSH
/// keys that reach the terminal interface.
class SecurityScreen extends ConsumerWidget {
  /// Creates the screen.
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return TixPage(
      title: l10n.securityTitle,
      subtitle: l10n.securitySubtitle,
      primaryAction: TixAction(
        key: const Key('security.addKey'),
        label: l10n.sshKeyAdd,
        icon: Icons.add,
        onPressed: () => addSshKey(context),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(secondFactorProvider)
            ..invalidate(sshKeysProvider);
          await ref.read(secondFactorProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: TixSpace.s7 * 2),
          children: const [_SecondFactorSection(), _SshKeySection()],
        ),
      ),
    );
  }
}

/// Opens the form that enrols an SSH key.
Future<void> addSshKey(BuildContext context) async {
  final added = await showTixSheet<Object>(
    context,
    builder: (_) => const _SshKeyForm(),
  );
  if (added != null && added != false && context.mounted) {
    showTixToast(context, context.l10n.sshKeyAdded);
  }
}

String _when(BuildContext context, DateTime t) => context.times.stamp(t);

class _SecondFactorSection extends ConsumerWidget {
  const _SecondFactorSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final value = ref.watch(secondFactorProvider);
    return TixSection(
      title: l10n.totpTitle,
      info: l10n.totpInfo,
      children: [
        value.when(
          loading: () => const SkeletonList(rows: 2, inline: true),
          error: (e, _) => ErrorState(
            error: e,
            compact: true,
            onRetry: () => ref.invalidate(secondFactorProvider),
          ),
          data: (status) => _SecondFactorBody(status: status),
        ),
      ],
    );
  }
}

class _SecondFactorBody extends ConsumerWidget {
  const _SecondFactorBody({required this.status});

  final TOTPStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final theme = Theme.of(context);
    final required = [
      if (status.requiredWeb) l10n.totpSurfaceWeb,
      if (status.requiredCli) l10n.totpSurfaceCli,
      if (status.requiredSsh) l10n.totpSurfaceSsh,
    ];
    final lockEnd = status.verificationLockEnd;
    return Padding(
      padding: const EdgeInsets.all(TixSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: TixSpace.s2,
            runSpacing: TixSpace.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (status.enrolled)
                TixBadge(
                  l10n.totpOn,
                  tone: TixTone.ok,
                  key: const Key('totp.state'),
                )
              else
                TixBadge(
                  status.pending ? l10n.totpPending : l10n.totpOff,
                  tone: required.isEmpty ? TixTone.neutral : TixTone.warn,
                  key: const Key('totp.state'),
                ),
              if (status.enrolled && status.confirmedAt != null)
                Text(
                  l10n.totpSince(_when(context, status.confirmedAt!)),
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
          const SizedBox(height: TixSpace.s2),
          Text(
            status.enrolled
                ? l10n.totpOnBody
                : status.pending
                ? l10n.totpPendingBody
                : l10n.totpOffBody,
          ),
          if (required.isNotEmpty) ...[
            const SizedBox(height: TixSpace.s2),
            Text(
              l10n.totpRequiredOn(required.join(', ')),
              key: const Key('totp.required'),
              style: TextStyle(color: status.enrolled ? t.muted : t.warn),
            ),
          ],
          if (status.enrolled) ...[
            const SizedBox(height: TixSpace.s2),
            Text(
              l10n.totpCodesLeft(status.recoveryCodesLeft),
              key: const Key('totp.codesLeft'),
              style: TextStyle(
                color: status.recoveryCodesLeft <= 2 ? t.warn : t.muted,
              ),
            ),
          ],
          if (status.verificationLocked && lockEnd != null) ...[
            const SizedBox(height: TixSpace.s2),
            Text(
              l10n.totpLocked(_when(context, lockEnd)),
              style: TextStyle(color: t.danger),
            ),
          ],
          const SizedBox(height: TixSpace.s3),
          Wrap(
            spacing: TixSpace.s2,
            runSpacing: TixSpace.s2,
            children: [
              if (!status.enrolled)
                TixButton(
                  key: const Key('totp.setup'),
                  label: l10n.totpSetUp,
                  icon: Icons.phonelink_lock_outlined,
                  onPressed: () => _setUp(context),
                ),
              if (status.enrolled) ...[
                TixButton(
                  key: const Key('totp.newCodes'),
                  label: l10n.totpNewCodes,
                  icon: Icons.refresh,
                  onPressed: () => _newCodes(context, ref),
                ),
                TixButton.danger(
                  key: const Key('totp.remove'),
                  label: l10n.totpRemove,
                  icon: Icons.no_encryption_outlined,
                  onPressed: () => _remove(context, ref),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _setUp(BuildContext context) async {
    final codes = await showTixSheet<Object>(
      context,
      dismissible: false,
      builder: (_) => const _EnrolSheet(),
    );
    if (codes is List<String> && context.mounted) {
      await showRecoveryCodes(context, codes);
    }
  }

  Future<void> _newCodes(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.totpNewCodes,
      body: l10n.totpNewCodesBody,
      action: l10n.totpNewCodesConfirm,
    );
    if (!ok || !context.mounted) return;
    try {
      final codes = await ref
          .read(secondFactorProvider.notifier)
          .newRecoveryCodes();
      if (context.mounted) await showRecoveryCodes(context, codes);
    } on Object catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.totpRemove,
      body: l10n.totpRemoveBody,
      action: l10n.totpRemove,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(secondFactorProvider.notifier).remove();
      if (context.mounted) showTixToast(context, l10n.totpRemoved);
    } on Object catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }
}

/// Shows recovery codes once, in a dialog that closes only with Done.
Future<void> showRecoveryCodes(BuildContext context, List<String> codes) {
  final l10n = context.l10n;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: TixMeasure.text),
        child: SingleChildScrollView(
          child: OneTimeSecret(
            key: const Key('totp.codes'),
            heading: l10n.totpCodesHeading,
            note: l10n.totpCodesNote,
            values: codes,
          ),
        ),
      ),
      actions: [
        TixButton.primary(
          key: const Key('totp.codesDone'),
          label: l10n.totpCodesSaved,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

/// Enrolment: the secret for an authenticator, then the code it shows.
/// Pops with the recovery codes once the server accepts the code.
class _EnrolSheet extends ConsumerStatefulWidget {
  const _EnrolSheet();

  @override
  ConsumerState<_EnrolSheet> createState() => _EnrolSheetState();
}

class _EnrolSheetState extends ConsumerState<_EnrolSheet> {
  final _code = TextEditingController();
  late final Future<TOTPEnrolment> _enrolment = ref
      .read(secondFactorProvider.notifier)
      .enrol();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder<TOTPEnrolment>(
      future: _enrolment,
      builder: (context, snap) {
        final enrolment = snap.data;
        if (snap.hasError) {
          return TixSheetBody(
            title: l10n.totpSetUp,
            actions: [
              TixButton.quiet(
                label: l10n.close,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
            child: Text(
              errorMessage(l10n, snap.error!),
              style: TextStyle(color: context.tix.danger),
            ),
          );
        }
        if (enrolment == null) {
          return TixSheetBody(
            title: l10n.totpSetUp,
            child: const SkeletonList(rows: 3, inline: true),
          );
        }
        return FormSheet(
          title: l10n.totpSetUp,
          submitLabel: l10n.totpConfirm,
          describe: (e) =>
              e is TixException && e.kind == TixErrorKind.unauthenticated
              ? l10n.totpWrongCode
              : null,
          onSubmit: () => ref
              .read(secondFactorProvider.notifier)
              .confirm(_code.text.trim()),
          children: [
            Text(l10n.totpStep1),
            formGap,
            OneTimeSecret(
              key: const Key('totp.secret'),
              heading: l10n.totpSecretHeading,
              note: l10n.totpSecretNote(enrolment.account, enrolment.issuer),
              values: [enrolment.secret],
            ),
            formGap,
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TixButton.quiet(
                key: const Key('totp.openApp'),
                label: l10n.totpOpenApp,
                icon: Icons.open_in_new,
                onPressed: () => unawaited(
                  ref
                      .read(attachmentsProvider)
                      .openLink(Uri.parse(enrolment.uri)),
                ),
              ),
            ),
            formGap,
            Text(l10n.totpStep2),
            formGap,
            TixTextField(
              fieldKey: const Key('totp.code'),
              label: l10n.codeLabel,
              controller: _code,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
            ),
          ],
        );
      },
    );
  }
}

class _SshKeySection extends ConsumerWidget {
  const _SshKeySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final value = ref.watch(sshKeysProvider);
    return TixSection(
      title: l10n.sshKeysTitle,
      info: l10n.sshKeysInfo,
      children: [
        value.when(
          loading: () => const SkeletonList(rows: 2, inline: true),
          error: (e, _) => ErrorState(
            error: e,
            compact: true,
            onRetry: () => ref.invalidate(sshKeysProvider),
          ),
          data: (keys) => keys.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(TixSpace.s4),
                  child: Text(
                    l10n.sshKeysEmpty,
                    key: const Key('sshKeys.empty'),
                  ),
                )
              : Column(children: [for (final k in keys) _SshKeyRow(sshKey: k)]),
        ),
      ],
    );
  }
}

class _SshKeyRow extends ConsumerWidget {
  const _SshKeyRow({required this.sshKey});

  final SSHKey sshKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final revoked = sshKey.revokedAt;
    final used = sshKey.lastUsedAt;
    final created = sshKey.createdAt;
    return ListTile(
      key: Key('sshKey.${sshKey.id}'),
      leading: Icon(
        Icons.vpn_key_outlined,
        color: revoked == null ? context.tix.muted : context.tix.lineStrong,
      ),
      title: Wrap(
        spacing: TixSpace.s2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(sshKey.label.isEmpty ? l10n.sshKeyUnlabelled : sshKey.label),
          if (revoked != null) TixBadge(l10n.sshKeyRevoked),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sshKey.fingerprint, style: tixMono(context)),
          Text(
            [
              if (created != null) l10n.sshKeyAddedOn(_when(context, created)),
              if (used != null)
                l10n.sshKeyLastUsed(_when(context, used))
              else
                l10n.sshKeyNeverUsed,
              if (revoked != null)
                l10n.sshKeyRevokedOn(_when(context, revoked)),
            ].join(' · '),
          ),
        ],
      ),
      isThreeLine: true,
      trailing: revoked != null
          ? null
          : TixButton.danger(
              key: Key('sshKey.revoke.${sshKey.id}'),
              label: l10n.sshKeyRevoke,
              size: TixButtonSize.small,
              onPressed: () => _revoke(context, ref),
            ),
    );
  }

  Future<void> _revoke(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final name = sshKey.label.isEmpty ? sshKey.fingerprint : sshKey.label;
    final ok = await confirmDestructive(
      context,
      title: l10n.sshKeyRevoke,
      body: l10n.sshKeyRevokeBody(name),
      action: l10n.sshKeyRevoke,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(sshKeysProvider.notifier).revoke(sshKey.id);
      if (context.mounted) showTixToast(context, l10n.sshKeyRevokedToast);
    } on Object catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }
}

class _SshKeyForm extends ConsumerStatefulWidget {
  const _SshKeyForm();

  @override
  ConsumerState<_SshKeyForm> createState() => _SshKeyFormState();
}

class _SshKeyFormState extends ConsumerState<_SshKeyForm> {
  final _label = TextEditingController();
  final _key = TextEditingController();
  var _everywhere = false;

  @override
  void dispose() {
    _label.dispose();
    _key.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FormSheet(
      title: l10n.sshKeyAdd,
      submitLabel: l10n.sshKeyAddSubmit,
      onSubmit: () => ref
          .read(sshKeysProvider.notifier)
          .add(
            EnrolSSHKeyInput(
              label: _label.text.trim(),
              publicKey: _key.text.trim(),
              allTenants: _everywhere ? true : null,
            ),
          ),
      children: [
        TixTextField(
          fieldKey: const Key('sshKey.publicKey'),
          label: l10n.sshKeyPublicKey,
          hint: 'ssh-ed25519 AAAA… you@laptop',
          help: l10n.sshKeyPublicKeyHelp,
          controller: _key,
          maxLines: 4,
        ),
        formGap,
        TixTextField(
          fieldKey: const Key('sshKey.label'),
          label: l10n.sshKeyLabel,
          help: l10n.sshKeyLabelHelp,
          controller: _label,
        ),
        formGap,
        TixSwitchRow(
          key: const Key('sshKey.allTenants'),
          title: l10n.sshKeyAllTenants,
          subtitle: l10n.sshKeyAllTenantsHelp,
          value: _everywhere,
          onChanged: (v) => setState(() => _everywhere = v),
        ),
      ],
    );
  }
}
