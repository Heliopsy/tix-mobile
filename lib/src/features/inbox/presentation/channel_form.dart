// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/features/inbox/application/channels.dart';
import 'package:tix_mobile/src/features/inbox/application/inbox.dart';
import 'package:tix_mobile/src/features/inbox/presentation/inbox_screen.dart';

/// The icon of a channel [format].
IconData channelFormatIcon(ChannelFormat? format) => switch (format) {
  ChannelFormat.slack => Icons.tag,
  ChannelFormat.discord => Icons.forum_outlined,
  ChannelFormat.ntfy => Icons.notifications_outlined,
  ChannelFormat.generic || null => Icons.webhook,
};

/// The name of a channel [format].
String channelFormatLabel(AppLocalizations l10n, ChannelFormat? format) =>
    switch (format) {
      ChannelFormat.slack => 'Slack',
      ChannelFormat.discord => 'Discord',
      ChannelFormat.ntfy => 'ntfy',
      ChannelFormat.generic || null => l10n.inboxChannelFormatGeneric,
    };

/// Opens the form for a new channel, then shows its secret once.
Future<void> addChannel(BuildContext context, WidgetRef ref) async {
  final created = await showTixSheet<IssuedInboxChannel>(
    context,
    builder: (_) => const ChannelForm(),
  );
  if (created == null || !context.mounted) return;
  showTixToast(context, context.l10n.inboxChannelAdded(created.name));
  if (created.secret.isNotEmpty) await showChannelSecret(context, created);
}

/// Opens the form for [channel].
Future<void> editChannel(BuildContext context, InboxChannel channel) async {
  final changed = await showTixSheet<Object>(
    context,
    builder: (_) => ChannelForm(channel: channel),
  );
  if (changed != null && context.mounted) {
    showTixToast(context, context.l10n.inboxChannelSaved);
  }
}

/// Shows a new channel's signing secret, which no later read returns.
Future<void> showChannelSecret(
  BuildContext context,
  IssuedInboxChannel channel,
) => showTixSheet<void>(
  context,
  builder: (context) {
    final l10n = context.l10n;
    return TixSheetBody(
      title: l10n.inboxChannelSecretTitle,
      actions: [
        TixButton(
          key: const Key('channel.secret.copy'),
          label: l10n.inboxChannelSecretCopy,
          icon: Icons.copy,
          onPressed: () =>
              unawaited(Clipboard.setData(ClipboardData(text: channel.secret))),
        ),
        TixButton.primary(
          key: const Key('channel.secret.done'),
          label: l10n.inboxChannelSecretDone,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.inboxChannelSecretBody),
          const SizedBox(height: TixSpace.s3),
          Container(
            padding: const EdgeInsets.all(TixSpace.s3),
            decoration: BoxDecoration(
              color: context.tix.surface,
              borderRadius: BorderRadius.circular(TixRadius.md),
            ),
            child: SelectableText(
              channel.secret,
              key: const Key('channel.secret'),
              style: tixMono(context),
            ),
          ),
        ],
      ),
    );
  },
);

/// Adds a channel, or changes [channel].
class ChannelForm extends ConsumerStatefulWidget {
  /// A form for a new channel, or for [channel].
  const ChannelForm({this.channel, super.key});

  /// The channel being changed; null for a new one.
  final InboxChannel? channel;

  @override
  ConsumerState<ChannelForm> createState() => _ChannelFormState();
}

class _ChannelFormState extends ConsumerState<ChannelForm> {
  late final _name = TextEditingController(text: widget.channel?.name ?? '');
  late final _url = TextEditingController(text: widget.channel?.url ?? '');
  late ChannelFormat _format = widget.channel?.format ?? ChannelFormat.generic;
  late Set<InboxKind> _kinds = {
    for (final k in widget.channel?.kinds ?? const <String>[])
      ?inboxKindNamed(k),
  };
  bool _busy = false;
  TixException? _error;

  @override
  void initState() {
    super.initState();
    if (_kinds.isEmpty) _kinds = inboxKinds.toSet();
  }

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    super.dispose();
  }

  String? _fieldError(String field) {
    final e = _error;
    if (e == null || e.details['field'] != field) return null;
    return e.message;
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final name = _name.text.trim();
    final url = _url.text.trim();
    final kinds = [
      for (final k in inboxKinds)
        if (_kinds.contains(k)) k.value,
    ];
    final channels = ref.read(channelsProvider.notifier);
    final existing = widget.channel;
    try {
      final saved = existing == null
          ? await channels.add(
              InboxChannelInput(
                name: name,
                url: url,
                format: _format.value,
                kinds: kinds,
              ),
            )
          : await channels.edit(
              existing.id,
              InboxChannelUpdate(
                name: name,
                url: url,
                format: _format.value,
                kinds: kinds,
              ),
            );
      if (mounted) Navigator.of(context).pop(saved);
    } on TixException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = _error;
    final general =
        error != null &&
        _fieldError('name') == null &&
        _fieldError('url') == null;
    return TixSheetBody(
      title: widget.channel == null
          ? l10n.inboxChannelAdd
          : l10n.inboxChannelEdit,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('channel.save'),
          label: widget.channel == null
              ? l10n.inboxChannelAdd
              : l10n.inboxChannelSave,
          busy: _busy,
          onPressed: _save,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TixTextField(
            fieldKey: const Key('channel.name'),
            label: l10n.inboxChannelName,
            controller: _name,
            hint: l10n.inboxChannelNameHint,
            error: _fieldError('name'),
            autofocus: widget.channel == null,
          ),
          const SizedBox(height: TixSpace.s3),
          TixTextField(
            fieldKey: const Key('channel.url'),
            label: l10n.inboxChannelUrl,
            controller: _url,
            hint: 'https://hooks.slack.com/services/…',
            help: l10n.inboxChannelUrlHelp,
            error: _fieldError('url'),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: TixSpace.s3),
          Text(
            l10n.inboxChannelFormat,
            style: TextStyle(fontSize: TixText.xs, color: context.tix.muted),
          ),
          const SizedBox(height: TixSpace.s2),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<ChannelFormat>(
              key: const Key('channel.format'),
              showSelectedIcon: false,
              segments: [
                for (final f in ChannelFormat.values)
                  ButtonSegment(
                    value: f,
                    icon: Icon(channelFormatIcon(f)),
                    label: Text(channelFormatLabel(l10n, f)),
                  ),
              ],
              selected: {_format},
              onSelectionChanged: (s) => setState(() => _format = s.first),
            ),
          ),
          const SizedBox(height: TixSpace.s3),
          Text(
            l10n.inboxChannelKinds,
            style: TextStyle(fontSize: TixText.xs, color: context.tix.muted),
          ),
          const SizedBox(height: TixSpace.s2),
          Wrap(
            spacing: TixSpace.s2,
            runSpacing: TixSpace.s2,
            children: [
              for (final kind in inboxKinds)
                TixFilterChip(
                  key: Key('channel.kind.${kind.value}'),
                  label: inboxKindLabel(l10n, kind),
                  icon: inboxKindIcon(kind),
                  selected: _kinds.contains(kind),
                  onSelected: (on) => setState(() {
                    if (on) {
                      _kinds = {..._kinds, kind};
                    } else if (_kinds.length > 1) {
                      _kinds = {..._kinds}..remove(kind);
                    }
                  }),
                ),
            ],
          ),
          if (general) ...[
            const SizedBox(height: TixSpace.s3),
            Text(
              errorMessage(l10n, error),
              key: const Key('channel.error'),
              style: TextStyle(color: context.tix.danger),
            ),
          ],
        ],
      ),
    );
  }
}
