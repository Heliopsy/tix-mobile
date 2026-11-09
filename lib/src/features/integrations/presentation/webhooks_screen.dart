// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/session/access.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/core/widgets/paged_list_view.dart';
import 'package:tix_mobile/src/data/models/integrations.dart';
import 'package:tix_mobile/src/data/models/scopes.dart';
import 'package:tix_mobile/src/features/integrations/application/webhooks.dart';

/// The tenant's webhook endpoints and their delivery log: register, edit,
/// test and remove endpoints, filter the log and redeliver. Two panes on a
/// wide window.
class WebhooksScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const WebhooksScreen({super.key});

  @override
  ConsumerState<WebhooksScreen> createState() => _WebhooksScreenState();
}

class _WebhooksScreenState extends ConsumerState<WebhooksScreen> {
  String _endpoint = '';
  String _status = '';

  Future<void> _edit([WebhookEndpoint? endpoint]) async {
    final saved = await showTixSheet<SavedWebhook>(
      context,
      builder: (_) => WebhookForm(endpoint: endpoint),
    );
    if (saved == null || !mounted) return;
    final secret = saved.generatedSecret;
    if (secret == null) {
      showTixToast(context, context.l10n.webhookSaved);
      return;
    }
    await showTixSheet<void>(
      context,
      dismissible: false,
      builder: (context) => _SecretSheet(secret: secret),
    );
  }

  Future<void> _delete(WebhookEndpoint endpoint) async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.webhookDeleteTitle,
      body: l10n.webhookDeleteBody(endpoint.url),
      action: l10n.webhookDelete,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(webhookEndpointsProvider.notifier).delete(endpoint.id);
      if (_endpoint == endpoint.id) setState(() => _endpoint = '');
      if (mounted) showTixToast(context, l10n.webhookDeleted);
    } on TixException catch (e) {
      if (mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }

  Future<void> _ping(WebhookEndpoint endpoint) async {
    final l10n = context.l10n;
    try {
      final delivery = await ref
          .read(webhookEndpointsProvider.notifier)
          .ping(endpoint.id);
      if (!mounted) return;
      await showTixSheet<void>(
        context,
        builder: (_) => PingResult(url: endpoint.url, delivery: delivery),
      );
    } on TixException catch (e) {
      if (mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }

  Future<void> _rowActions(
    WebhookEndpoint endpoint, {
    required bool admin,
  }) async {
    final l10n = context.l10n;
    final canTest = admin && endpoint.active;
    final choice = await showActionSheet<String>(
      context,
      title: endpoint.url,
      actions: [
        TixSheetAction(
          value: 'edit',
          label: l10n.webhookEdit,
          icon: Icons.edit_outlined,
        ),
        if (canTest)
          TixSheetAction(
            key: const Key('webhook.ping'),
            value: 'ping',
            label: l10n.webhookPing,
            icon: Icons.send_outlined,
          ),
        TixSheetAction(
          value: 'deliveries',
          label: l10n.webhookShowDeliveries,
          icon: Icons.history,
        ),
        TixSheetAction(
          key: const Key('webhook.delete'),
          value: 'delete',
          label: l10n.webhookDelete,
          icon: Icons.delete_outline,
          destructive: true,
        ),
      ],
    );
    switch (choice) {
      case 'edit':
        await _edit(endpoint);
      case 'ping':
        await _ping(endpoint);
      case 'deliveries':
        setState(() => _endpoint = endpoint.id);
      case 'delete':
        await _delete(endpoint);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final endpoints = ref.watch(webhookEndpointsProvider);
    final admin =
        ref.watch(currentAccessProvider).value?.can(Scopes.webhookAdmin) ??
        false;
    final newEndpoint = TixAction(
      key: const Key('webhooks.new'),
      label: l10n.webhookNew,
      icon: Icons.add,
      onPressed: _edit,
    );
    final deliveries = webhookDeliveriesProvider(
      endpointId: _endpoint,
      status: _status,
    );
    Widget endpointList(List<WebhookEndpoint> items) => _EndpointList(
      endpoints: items,
      selected: _endpoint,
      action: newEndpoint,
      onTap: (e) => _rowActions(e, admin: admin),
    );
    Widget filters(List<WebhookEndpoint> items) => _DeliveryFilters(
      status: _status,
      endpoint: [
        for (final e in items)
          if (e.id == _endpoint) e.url,
      ].firstOrNull,
      onStatus: (s) => setState(() => _status = s),
      onClearEndpoint: () => setState(() => _endpoint = ''),
    );
    return TixPage(
      title: l10n.webhooksTitle,
      subtitle: l10n.webhooksSubtitle,
      primaryAction: newEndpoint,
      body: AsyncBody(
        value: endpoints,
        onRetry: () => ref.invalidate(webhookEndpointsProvider),
        data: (items) {
          final log = _DeliveryLog(
            provider: deliveries,
            header: context.isTwoPane
                ? filters(items)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [endpointList(items), filters(items)],
                  ),
          );
          if (!context.isTwoPane) return log;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: SingleChildScrollView(child: endpointList(items)),
              ),
              VerticalDivider(width: 1, color: context.tix.line),
              Expanded(flex: 3, child: log),
            ],
          );
        },
      ),
    );
  }
}

class _EndpointList extends StatelessWidget {
  const _EndpointList({
    required this.endpoints,
    required this.selected,
    required this.action,
    required this.onTap,
  });

  final List<WebhookEndpoint> endpoints;
  final String selected;
  final TixAction action;
  final ValueChanged<WebhookEndpoint> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (endpoints.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(TixSpace.s4),
        child: EmptyState(
          icon: Icons.webhook_outlined,
          title: l10n.webhooksEmpty,
          body: l10n.webhooksEmptyBody,
          action: action,
        ),
      );
    }
    return TixSection(
      title: l10n.webhookEndpoints,
      info: l10n.webhookEndpointsInfo,
      children: [
        for (final e in endpoints)
          ListTile(
            key: Key('webhook.${e.id}'),
            selected: e.id == selected,
            leading: const Icon(Icons.webhook_outlined),
            title: Text(e.url, style: tixMono(context, size: TixText.sm)),
            subtitle: Text(
              e.eventTypes.isEmpty
                  ? l10n.webhookEveryEvent
                  : e.eventTypes.join(', '),
            ),
            trailing: TixBadge(
              e.active ? l10n.webhookActive : l10n.webhookInactive,
              tone: e.active ? TixTone.ok : TixTone.neutral,
            ),
            onTap: () => onTap(e),
          ),
      ],
    );
  }
}

class _DeliveryFilters extends StatelessWidget {
  const _DeliveryFilters({
    required this.status,
    required this.endpoint,
    required this.onStatus,
    required this.onClearEndpoint,
  });

  final String status;
  final String? endpoint;
  final ValueChanged<String> onStatus;
  final VoidCallback onClearEndpoint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final endpoint = this.endpoint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.webhookDeliveries,
          subtitle: endpoint == null
              ? l10n.webhookDeliveriesAll
              : l10n.webhookDeliveriesFor(endpoint),
          trailing: endpoint == null
              ? null
              : TixButton.quiet(
                  key: const Key('deliveries.all'),
                  label: l10n.webhookDeliveriesShowAll,
                  size: TixButtonSize.small,
                  onPressed: onClearEndpoint,
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TixSpace.s4),
          child: Wrap(
            spacing: TixSpace.s2,
            runSpacing: TixSpace.s2,
            children: [
              for (final (value, label) in [
                ('', l10n.webhookStatusAny),
                ('pending', l10n.webhookStatusPending),
                ('delivered', l10n.webhookStatusDelivered),
                ('failed', l10n.webhookStatusFailed),
              ])
                TixFilterChip(
                  key: Key('deliveries.status.$value'),
                  label: label,
                  selected: status == value,
                  onSelected: (_) => onStatus(value),
                ),
            ],
          ),
        ),
        const SizedBox(height: TixSpace.s2),
      ],
    );
  }
}

class _DeliveryLog extends ConsumerWidget {
  const _DeliveryLog({required this.provider, required this.header});

  final WebhookDeliveriesProvider provider;
  final Widget header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AsyncBody(
      value: ref.watch(provider),
      onRetry: () => ref.invalidate(provider),
      data: (paged) => PagedListView(
        paged: paged,
        header: header,
        padding: const EdgeInsets.only(bottom: TixSpace.s7 * 2),
        empty: EmptyState(
          icon: Icons.outbox_outlined,
          title: l10n.webhookDeliveriesEmpty,
          body: l10n.webhookDeliveriesEmptyBody,
        ),
        onRefresh: () => ref.refresh(provider.future),
        onLoadMore: () => ref.read(provider.notifier).loadMore(),
        itemBuilder: (context, d) => DeliveryRow(
          delivery: d,
          onRedeliver: () => _redeliver(context, ref, d),
        ),
      ),
    );
  }

  Future<void> _redeliver(
    BuildContext context,
    WidgetRef ref,
    WebhookDelivery d,
  ) async {
    final l10n = context.l10n;
    try {
      await ref.read(provider.notifier).redeliver(d.id);
      if (context.mounted) showTixToast(context, l10n.webhookRedelivered);
    } on TixException catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }
}

(String, TixTone) _statusOf(AppLocalizations l10n, DeliveryStatus? status) =>
    switch (status) {
      DeliveryStatus.delivered => (l10n.webhookStatusDelivered, TixTone.ok),
      DeliveryStatus.failed => (l10n.webhookStatusFailed, TixTone.danger),
      DeliveryStatus.pending => (l10n.webhookStatusPending, TixTone.warn),
      null => (l10n.webhookStatusUnknown, TixTone.neutral),
    };

/// What a test event to [url] came to: the delivery tix answered, with its
/// status, the endpoint's HTTP status, the attempts and the last error.
class PingResult extends StatelessWidget {
  /// Shows [delivery], the test sent to [url].
  const PingResult({required this.url, required this.delivery, super.key});

  /// The endpoint's address.
  final String url;

  /// The delivery tix queued for the test.
  final WebhookDelivery delivery;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final d = delivery;
    final (label, tone) = _statusOf(l10n, d.status);
    return TixSheetBody(
      title: l10n.webhookPingTitle,
      actions: [
        TixButton.primary(
          key: const Key('ping.done'),
          label: l10n.close,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      child: Column(
        key: const Key('ping.result'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.webhookPingSent(url)),
          const SizedBox(height: TixSpace.s3),
          Wrap(
            spacing: TixSpace.s2,
            runSpacing: TixSpace.s1,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TixBadge(label, tone: tone, key: const Key('ping.status')),
              if (d.lastStatusCode != 0)
                Text(l10n.webhookHttpStatus(d.lastStatusCode)),
              Text(
                l10n.webhookAttempts(d.attempts),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (d.status == DeliveryStatus.pending) ...[
            const SizedBox(height: TixSpace.s2),
            Text(l10n.webhookPingPending),
          ],
          if (d.lastError.isNotEmpty) ...[
            const SizedBox(height: TixSpace.s2),
            Text(
              d.lastError,
              style: tixMono(context, size: TixText.xs, color: t.danger),
            ),
          ],
        ],
      ),
    );
  }
}

/// One delivery: its status, the event, the attempts and the last answer,
/// with Redeliver.
class DeliveryRow extends StatelessWidget {
  /// Draws [delivery].
  const DeliveryRow({
    required this.delivery,
    required this.onRedeliver,
    super.key,
  });

  /// The delivery.
  final WebhookDelivery delivery;

  /// Queues it again.
  final VoidCallback onRedeliver;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final d = delivery;
    String when(DateTime at) => context.times.stamp(at);
    final (label, tone) = _statusOf(l10n, d.status);
    final created = d.createdAt;
    final next = d.nextAttemptAt;
    return Container(
      key: Key('delivery.${d.id}'),
      padding: const EdgeInsets.symmetric(
        horizontal: TixSpace.s4,
        vertical: TixSpace.s3,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: TixSpace.s2,
                  runSpacing: TixSpace.s1,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TixBadge(label, tone: tone),
                    Text(l10n.webhookEvent(d.eventSeq)),
                    Text(
                      l10n.webhookAttempts(d.attempts),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: TixSpace.s1),
                Text(
                  [
                    if (created != null) when(created),
                    if (d.lastStatusCode != 0)
                      l10n.webhookHttpStatus(d.lastStatusCode),
                    if (next != null && d.status == DeliveryStatus.pending)
                      l10n.webhookNextAttempt(when(next)),
                  ].join(' · '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (d.lastError.isNotEmpty) ...[
                  const SizedBox(height: TixSpace.s1),
                  Text(
                    d.lastError,
                    style: tixMono(context, size: TixText.xs, color: t.danger),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: TixSpace.s2),
          TixButton(
            key: Key('delivery.${d.id}.redeliver'),
            label: l10n.webhookRedeliver,
            icon: Icons.replay,
            size: TixButtonSize.small,
            onPressed: onRedeliver,
          ),
        ],
      ),
    );
  }
}

/// Registers a webhook endpoint or edits [endpoint]; pops with what was
/// saved.
class WebhookForm extends ConsumerStatefulWidget {
  /// A form for a new endpoint, or for [endpoint].
  const WebhookForm({this.endpoint, super.key});

  /// The endpoint being edited, null for a new one.
  final WebhookEndpoint? endpoint;

  @override
  ConsumerState<WebhookForm> createState() => _WebhookFormState();
}

class _WebhookFormState extends ConsumerState<WebhookForm> {
  late final _url = TextEditingController(text: widget.endpoint?.url ?? '');
  late final _events = TextEditingController(
    text: widget.endpoint?.eventTypes.join(', ') ?? '',
  );
  final _secret = TextEditingController();
  late bool _active = widget.endpoint?.active ?? true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _url.dispose();
    _events.dispose();
    _secret.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final saved = await ref
          .read(webhookEndpointsProvider.notifier)
          .save(
            id: widget.endpoint?.id,
            url: _url.text.trim(),
            eventTypes: [
              for (final e in _events.text.split(RegExp(r'[,\s]+')))
                if (e.isNotEmpty) e,
            ],
            active: _active,
            secret: _secret.text,
          );
      if (mounted) Navigator.of(context).pop(saved);
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
    final editing = widget.endpoint != null;
    return TixSheetBody(
      title: editing ? l10n.webhookEdit : l10n.webhookNew,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('webhook.save'),
          label: l10n.webhookSave,
          busy: _busy,
          onPressed: _save,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TixTextField(
            fieldKey: const Key('webhook.url'),
            label: l10n.webhookUrl,
            controller: _url,
            hint: 'https://example.com/tix',
            help: l10n.webhookUrlHelp,
            error: _error,
            keyboardType: TextInputType.url,
            autofocus: !editing,
          ),
          const SizedBox(height: TixSpace.s3),
          TixTextField(
            fieldKey: const Key('webhook.events'),
            label: l10n.webhookEvents,
            controller: _events,
            hint: 'task.*, comment.added',
            help: l10n.webhookEventsHelp,
          ),
          const SizedBox(height: TixSpace.s3),
          TixTextField(
            fieldKey: const Key('webhook.secret'),
            label: l10n.webhookSecret,
            controller: _secret,
            obscure: true,
            help: editing
                ? l10n.webhookSecretKeepHelp
                : l10n.webhookSecretNewHelp,
          ),
          const SizedBox(height: TixSpace.s2),
          TixSwitchRow(
            key: const Key('webhook.active'),
            title: l10n.webhookActive,
            subtitle: l10n.webhookActiveHelp,
            value: _active,
            onChanged: (v) => setState(() => _active = v),
          ),
        ],
      ),
    );
  }
}

class _SecretSheet extends StatelessWidget {
  const _SecretSheet({required this.secret});

  final String secret;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TixSheetBody(
      title: l10n.webhookSaved,
      actions: [
        TixButton.primary(
          key: const Key('secret.done'),
          label: l10n.webhookSecretDone,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      child: OneTimeSecret(
        heading: l10n.webhookSecretHeading,
        note: l10n.webhookSecretNote,
        values: [secret],
      ),
    );
  }
}
