// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/durations.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/features/status/application/status.dart';

/// What `tix status` reports: the build and schema, the server processes
/// and whether each still heartbeats, the tenant's work and its second
/// factor. It only reads.
class StatusScreen extends ConsumerWidget {
  /// Creates the screen.
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).value;
    return TixPage(
      title: l10n.statusTitle,
      subtitle: session?.instance.name,
      body: AsyncBody(
        value: ref.watch(statusReportStateProvider),
        onRetry: () => ref.invalidate(statusReportStateProvider),
        data: (report) => RefreshIndicator(
          onRefresh: () => ref.refresh(statusReportStateProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: TixSpace.s6),
            children: [
              _Installation(report: report),
              _Servers(report: report),
              if (report.work case final work?) _Work(work: work),
              if (report.secondFactor case final totp?)
                _SecondFactor(report: totp),
            ],
          ),
        ),
      ),
    );
  }
}

String _moment(BuildContext context, DateTime? at) {
  if (at == null) return '—';
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMd(locale).add_Hm().format(at.toLocal());
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.tone});

  final String label;
  final String value;
  final Color? tone;

  @override
  Widget build(BuildContext context) => TixPropertyRow(
    label: label,
    child: Text(
      value,
      style: tone == null
          ? null
          : TextStyle(color: tone, fontWeight: FontWeight.w600),
    ),
  );
}

class _Installation extends StatelessWidget {
  const _Installation({required this.report});

  final StatusReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final i = report.installation;
    return TixSection(
      key: const Key('status.installation'),
      title: l10n.statusInstallation,
      children: [
        _Row(l10n.statusVersion, i?.version ?? '—'),
        _Row(l10n.statusSchema, '${i?.schemaVersion ?? 0}'),
        _Row(l10n.statusEngine, i?.engine ?? '—'),
        if (report.answeringServer.isNotEmpty)
          _Row(l10n.statusAnswering, report.answeringServer),
        _Row(l10n.statusObserved, _moment(context, i?.observedAt)),
      ],
    );
  }
}

class _Servers extends StatelessWidget {
  const _Servers({required this.report});

  final StatusReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    return TixSection(
      key: const Key('status.servers'),
      title: l10n.statusServers,
      info: l10n.statusServersInfo,
      children: [
        if (report.servers.isEmpty)
          Padding(
            padding: const EdgeInsets.all(TixSpace.s4),
            child: Text(
              l10n.statusNoServers,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        for (final s in report.servers)
          ListTile(
            key: Key('status.server.${s.id}'),
            leading: Icon(
              s.attached ? Icons.check_circle_outline : Icons.error_outline,
              color: s.attached ? t.ok : t.danger,
            ),
            title: Text(s.address.isEmpty ? s.id : s.address),
            subtitle: Text(
              [
                if (s.attached)
                  l10n.statusAttached
                else
                  l10n.statusDetached(_moment(context, s.lastSeenAt)),
                if (s.version.isNotEmpty) s.version,
                if (s.uptime.isNotEmpty)
                  l10n.statusUptime(humanDuration(l10n, s.uptime)),
                if (s.connections case final n?) l10n.statusConnections(n),
              ].join(' · '),
            ),
          ),
      ],
    );
  }
}

class _Work extends StatelessWidget {
  const _Work({required this.work});

  final Work work;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    return TixSection(
      key: const Key('status.work'),
      title: l10n.statusWork,
      children: [
        _Row(l10n.statusProjects, '${work.projects}'),
        _Row(l10n.statusTasks, '${work.tasks}'),
        _Row(l10n.statusClaimed, '${work.claimed}'),
        if (work.leasesExpiredUnswept > 0)
          _Row(
            l10n.statusUnswept,
            '${work.leasesExpiredUnswept}',
            tone: t.warn,
          ),
        _Row(l10n.statusWebhooksPending, '${work.webhooksPending}'),
        _Row(
          l10n.statusWebhooksFailed,
          '${work.webhooksFailed}',
          tone: work.webhooksFailed > 0 ? t.danger : null,
        ),
      ],
    );
  }
}

class _SecondFactor extends StatelessWidget {
  const _SecondFactor({required this.report});

  final TOTPReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    String yesNo({required bool on}) => on ? l10n.statusYes : l10n.statusNo;
    return TixSection(
      key: const Key('status.totp'),
      title: l10n.statusSecondFactor,
      children: [
        _Row(
          l10n.statusKey,
          yesNo(on: report.keyConfigured),
          tone: report.keyConfigured ? null : t.warn,
        ),
        _Row(l10n.statusRequireWeb, yesNo(on: report.requireWeb)),
        _Row(l10n.statusRequireCli, yesNo(on: report.requireCli)),
        _Row(l10n.statusRequireSsh, yesNo(on: report.requireSsh)),
        _Row(
          l10n.statusAdmins,
          l10n.statusAdminsEnrolled(report.enrolledAdmins, report.admins),
        ),
        if (report.unrecoverable)
          Padding(
            key: const Key('status.unrecoverable'),
            padding: const EdgeInsets.all(TixSpace.s3),
            child: Text(
              l10n.statusUnrecoverable,
              style: TextStyle(color: t.danger),
            ),
          ),
      ],
    );
  }
}
