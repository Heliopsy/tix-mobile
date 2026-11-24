// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/dav_handoff.dart';

/// The address, the user name and, once issued, the password, each with a
/// copy button labelled with the field it copies. The password is hidden
/// until revealed, to the eye and to screen readers alike.
class DavDetails extends StatefulWidget {
  /// Shows [address] and [username], and [password] when given.
  const DavDetails({
    required this.address,
    required this.username,
    this.password,
    super.key,
  });

  /// The CalDAV address.
  final String address;

  /// tix's Basic user name.
  final String username;

  /// The app password, held only by the sheet that shows it.
  final String? password;

  @override
  State<DavDetails> createState() => _DavDetailsState();
}

class _DavDetailsState extends State<DavDetails> {
  var _revealed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final password = widget.password;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DetailRow(
          id: 'dav.detail.address',
          label: l10n.davAddress,
          value: widget.address,
          copyLabel: l10n.davCopyAddress,
          onCopy: () => _copyPlain(context, widget.address),
        ),
        _DetailRow(
          id: 'dav.detail.username',
          label: l10n.davUsername,
          value: widget.username,
          copyLabel: l10n.davCopyUsername,
          onCopy: () => _copyPlain(context, widget.username),
        ),
        if (password != null)
          _DetailRow(
            id: 'dav.detail.password',
            label: l10n.davPassword,
            value: password,
            hidden: !_revealed,
            copyLabel: l10n.davCopyPassword,
            onCopy: () => _copySecret(context, password),
            reveal: TixIconButton(
              key: const Key('dav.reveal'),
              icon: _revealed
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              tooltip: _revealed ? l10n.davHidePassword : l10n.davShowPassword,
              onPressed: () => setState(() => _revealed = !_revealed),
            ),
          ),
      ],
    );
  }

  void _copyPlain(BuildContext context, String value) {
    unawaited(Clipboard.setData(ClipboardData(text: value)));
    showTixToast(context, context.l10n.copiedToClipboard);
  }

  Future<void> _copySecret(BuildContext context, String value) async {
    final l10n = context.l10n;
    final container = ProviderScope.containerOf(context, listen: false);
    final mark = await container.read(davHandoffProvider).copySecret(value);
    if (!context.mounted) return;
    showTixToast(context, switch (mark) {
      ClipMark.expires => l10n.davCopiedExpires,
      ClipMark.hidden => l10n.davCopiedHidden,
      ClipMark.plain => l10n.davCopiedPlain,
    });
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.id,
    required this.label,
    required this.value,
    required this.copyLabel,
    required this.onCopy,
    this.hidden = false,
    this.reveal,
  });

  final String id;
  final String label;
  final String value;
  final String copyLabel;
  final VoidCallback onCopy;
  final bool hidden;
  final Widget? reveal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final reveal = this.reveal;
    return Padding(
      key: Key(id),
      padding: const EdgeInsets.symmetric(vertical: TixSpace.s1),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelMedium),
                Semantics(
                  label: label,
                  value: hidden ? l10n.davPasswordHidden : value,
                  excludeSemantics: true,
                  child: hidden
                      ? Text(
                          '••••••••••••',
                          key: const Key('dav.hidden'),
                          style: tixMono(context),
                        )
                      : SelectableText(value, style: tixMono(context)),
                ),
              ],
            ),
          ),
          ?reveal,
          TixIconButton(
            key: Key('$id.copy'),
            icon: Icons.copy,
            tooltip: copyLabel,
            onPressed: onCopy,
          ),
        ],
      ),
    );
  }
}
