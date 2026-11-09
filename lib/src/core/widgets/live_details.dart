// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/events/events.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/app_info.dart';

/// Opens the connection details of the active context's live updates.
Future<void> showLiveDetails(BuildContext context) =>
    showTixSheet<void>(context, builder: (_) => const LiveDetailsSheet());

/// What a failure or a mode may mean, for the connection details.
enum LiveHint {
  /// Something between the app and tix drops idle connections.
  idleTimeout,

  /// Something between the app and tix does not forward WebSocket upgrades.
  noUpgrade,

  /// The phone could not reach the host.
  unreachable,

  /// The certificate was not accepted.
  tls,

  /// The credential may not follow live updates.
  refused,

  /// The server answered a poll with an HTTP error.
  http,

  /// The server predates the poll endpoint.
  pollMissing,
}

/// The hints that fit [d], most specific first.
List<LiveHint> liveHints(LiveDiagnostics d) {
  final e = d.lastError;
  final hints = <LiveHint>[
    if (e != null)
      ?switch (e.kind) {
        LiveErrorKind.timeout => LiveHint.idleTimeout,
        LiveErrorKind.closed
            when const {null, 1001, 1006}.contains(e.closeCode) =>
          LiveHint.idleTimeout,
        LiveErrorKind.upgradeRefused => LiveHint.noUpgrade,
        LiveErrorKind.unreachable => LiveHint.unreachable,
        LiveErrorKind.tls => LiveHint.tls,
        LiveErrorKind.refused => LiveHint.refused,
        LiveErrorKind.http => LiveHint.http,
        LiveErrorKind.closed || LiveErrorKind.other => null,
      },
  ];
  if (d.mode == LiveMode.polling && !hints.contains(LiveHint.noUpgrade)) {
    hints.add(LiveHint.noUpgrade);
  }
  if (d.pollUnsupported) hints.add(LiveHint.pollMissing);
  return hints;
}

/// The connection details: how live updates arrive, what failed last and
/// what it may mean, with Reconnect now and Copy details.
class LiveDetailsSheet extends ConsumerWidget {
  /// Creates the sheet.
  const LiveDetailsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final d = ref.watch(liveDiagnosticsProvider).value;
    final format = _Times(context, ref.watch(clockProvider)());
    return TixSheetBody(
      key: const Key('live.details'),
      title: l10n.liveDetailsTitle,
      actions: [
        TixButton.quiet(
          key: const Key('live.details.copy'),
          label: l10n.liveDetailsCopy,
          icon: Icons.copy_outlined,
          onPressed: d == null ? null : () => _copy(context, ref, d),
        ),
        TixButton.primary(
          key: const Key('live.details.reconnect'),
          label: l10n.liveDetailsReconnect,
          icon: Icons.refresh,
          onPressed: d == null || !_canRetry(d.mode)
              ? null
              : () => ref.read(tixEventStreamProvider)?.retryNow(),
        ),
      ],
      child: d == null
          ? Text(l10n.liveDetailsNone)
          : _Details(
              diagnostics: d,
              times: format,
              refreshSeconds: ref
                  .watch(liveConfigProvider)
                  .refreshEvery
                  .inSeconds,
            ),
    );
  }

  static bool _canRetry(LiveMode mode) =>
      mode != LiveMode.paused && mode != LiveMode.closed;

  Future<void> _copy(
    BuildContext context,
    WidgetRef ref,
    LiveDiagnostics d,
  ) async {
    final copied = context.l10n.liveDetailsCopied;
    final app = ref.read(appInfoProvider).value;
    await Clipboard.setData(
      ClipboardData(
        text: d.toReport(
          app: app == null
              ? ''
              : app.build.isEmpty
              ? app.version
              : '${app.version} (${app.build})',
          platform: app == null ? '' : '${app.platform} ${app.osVersion}',
        ),
      ),
    );
    if (context.mounted) showTixToast(context, copied);
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.diagnostics,
    required this.times,
    required this.refreshSeconds,
  });

  final LiveDiagnostics diagnostics;
  final _Times times;
  final int refreshSeconds;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final d = diagnostics;
    final e = d.lastError;
    final hints = liveHints(d);
    Widget row(String label, String value, [String? id]) => TixPropertyRow(
      label: label,
      child: Text(value, key: id == null ? null : Key('live.details.$id')),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _modeInfo(l10n, d, refreshSeconds),
          key: const Key('live.details.summary'),
          style: TextStyle(color: t.muted),
        ),
        const SizedBox(height: TixSpace.s4),
        TixPropertyList(
          children: [
            row(l10n.liveDetailsServer, d.host, 'host'),
            row(l10n.liveDetailsMode, _modeLabel(l10n, d.mode), 'mode'),
            row(l10n.liveDetailsTransport, _transport(l10n, d.transport)),
            row(l10n.liveDetailsSince, times.at(d.modeSince)),
            row(l10n.liveDetailsLastContact, times.maybe(d.lastContactAt)),
            row(l10n.liveDetailsLastEvent, times.maybe(d.lastEventAt)),
            row(
              l10n.liveDetailsFailuresInRow,
              '${d.consecutiveFailures}',
              'failures',
            ),
            row(
              l10n.liveDetailsWindowFailures,
              l10n.liveDetailsWindowValue(
                d.windowFailures,
                d.failuresBeforeFallback,
                d.failureWindow.inMinutes,
              ),
              'window',
            ),
            row(
              l10n.liveDetailsPollEndpoint,
              d.pollUnsupported
                  ? l10n.liveDetailsPollMissing
                  : l10n.liveDetailsPollAvailable,
            ),
            if (d.nextRetryAt case final next?)
              row(l10n.liveDetailsNextRetry, times.at(next), 'retry'),
            if (d.nextProbeAt case final next?)
              row(l10n.liveDetailsNextProbe, times.at(next), 'probe'),
          ],
        ),
        const SizedBox(height: TixSpace.s5),
        _Heading(l10n.liveDetailsLastError),
        if (e == null)
          Text(l10n.liveDetailsNoError, key: const Key('live.details.noError'))
        else
          TixPropertyList(
            key: const Key('live.details.error'),
            children: [
              row(l10n.liveDetailsErrorWhat, _kind(l10n, e.kind), 'kind'),
              row(l10n.liveDetailsErrorAt, times.at(e.at)),
              row(l10n.liveDetailsErrorSource, _source(l10n, e.source)),
              row(l10n.liveDetailsErrorType, e.type, 'type'),
              if (e.httpStatus != null)
                row(l10n.liveDetailsHttpStatus, '${e.httpStatus}', 'status'),
              if (e.osErrorMessage != null || e.osErrorCode != null)
                row(
                  l10n.liveDetailsOsError,
                  l10n.liveDetailsOsErrorValue(
                    e.osErrorMessage ?? '',
                    '${e.osErrorCode ?? '?'}',
                  ),
                  'os',
                ),
              if (e.closeCode != null || (e.closeReason ?? '').isNotEmpty)
                row(
                  l10n.liveDetailsCloseCode,
                  [
                    if (e.closeCode != null) '${e.closeCode}',
                    if ((e.closeReason ?? '').isNotEmpty) e.closeReason!,
                  ].join(' · '),
                  'close',
                ),
              if (e.message.isNotEmpty)
                row(l10n.liveDetailsErrorMessage, e.message, 'message'),
            ],
          ),
        if (hints.isNotEmpty) ...[
          const SizedBox(height: TixSpace.s5),
          _Heading(l10n.liveDetailsHints),
          for (final h in hints)
            Padding(
              padding: const EdgeInsets.only(bottom: TixSpace.s2),
              child: TixNotice(
                _hint(l10n, h, e),
                key: Key('live.details.hint.${h.name}'),
                tone: h == LiveHint.pollMissing
                    ? TixNoticeTone.info
                    : TixNoticeTone.warn,
              ),
            ),
        ],
        const SizedBox(height: TixSpace.s5),
        _Heading(l10n.liveDetailsHistory),
        if (d.history.isEmpty)
          Text(l10n.liveDetailsHistoryEmpty)
        else
          for (final entry in d.history.reversed)
            _HistoryLine(entry: entry, times: times),
      ],
    );
  }

  static String _modeInfo(
    AppLocalizations l10n,
    LiveDiagnostics d,
    int refreshSeconds,
  ) => switch (d.mode) {
    LiveMode.websocket => l10n.liveStatusLiveInfo,
    LiveMode.connecting => l10n.liveStatusConnectingInfo,
    LiveMode.polling => l10n.liveStatusPollingInfo,
    LiveMode.refreshing => l10n.liveStatusRefreshingInfo(refreshSeconds),
    LiveMode.offline => l10n.liveStatusOfflineInfo,
    LiveMode.unavailable => l10n.liveStatusUnavailableInfo,
    LiveMode.paused => l10n.liveDetailsPausedInfo,
    LiveMode.closed => l10n.liveDetailsNone,
  };

  static String _transport(AppLocalizations l10n, LiveTransport t) =>
      switch (t) {
        LiveTransport.websocket => l10n.liveTransportWebsocket,
        LiveTransport.poll => l10n.liveTransportPoll,
        LiveTransport.refresh => l10n.liveTransportRefresh,
        LiveTransport.none => l10n.liveTransportNone,
      };

  static String _source(AppLocalizations l10n, LiveErrorSource s) =>
      switch (s) {
        LiveErrorSource.websocket => l10n.liveTransportWebsocket,
        LiveErrorSource.probe => l10n.liveSourceProbe,
        LiveErrorSource.poll => l10n.liveSourcePoll,
      };

  static String _hint(AppLocalizations l10n, LiveHint h, LiveError? e) =>
      switch (h) {
        LiveHint.idleTimeout => l10n.liveHintIdleTimeout,
        LiveHint.noUpgrade => l10n.liveHintNoUpgrade,
        LiveHint.unreachable => l10n.liveHintUnreachable,
        LiveHint.tls => l10n.liveHintTls,
        LiveHint.refused => l10n.liveHintRefused,
        LiveHint.http => l10n.liveHintHttp('${e?.httpStatus ?? '?'}'),
        LiveHint.pollMissing => l10n.liveHintPollMissing,
      };
}

/// The label of [mode], as the indicator words it.
String _modeLabel(AppLocalizations l10n, LiveMode mode) => switch (mode) {
  LiveMode.websocket => l10n.liveStatusLive,
  LiveMode.connecting => l10n.liveStatusConnecting,
  LiveMode.polling => l10n.liveStatusPolling,
  LiveMode.refreshing => l10n.liveStatusRefreshing,
  LiveMode.offline => l10n.liveStatusOffline,
  LiveMode.unavailable => l10n.liveStatusUnavailable,
  LiveMode.paused => l10n.liveDetailsModePaused,
  LiveMode.closed => l10n.liveDetailsModeClosed,
};

String _kind(AppLocalizations l10n, LiveErrorKind k) => switch (k) {
  LiveErrorKind.unreachable => l10n.liveErrorUnreachable,
  LiveErrorKind.timeout => l10n.liveErrorTimeout,
  LiveErrorKind.tls => l10n.liveErrorTls,
  LiveErrorKind.upgradeRefused => l10n.liveErrorUpgradeRefused,
  LiveErrorKind.closed => l10n.liveErrorClosed,
  LiveErrorKind.refused => l10n.liveErrorRefused,
  LiveErrorKind.http => l10n.liveErrorHttp,
  LiveErrorKind.other => l10n.liveErrorOther,
};

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: TixSpace.s2),
    child: Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    ),
  );
}

class _HistoryLine extends StatelessWidget {
  const _HistoryLine({required this.entry, required this.times});

  final LiveLogEntry entry;
  final _Times times;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final e = entry.error;
    final what = e == null
        ? _modeLabel(l10n, entry.mode)
        : l10n.liveDetailsHistoryError(
            _kind(l10n, e.kind),
            _Details._source(l10n, e.source),
          );
    return Padding(
      padding: const EdgeInsets.only(bottom: TixSpace.s1),
      child: MergeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              times.at(entry.at),
              style: TextStyle(
                color: t.muted,
                fontSize: TixText.sm,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: TixSpace.s3),
            Expanded(
              child: Text(
                what,
                style: TextStyle(
                  fontSize: TixText.sm,
                  color: e == null ? null : t.danger,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Writes instants as the time of day, with the date when it is not today.
class _Times {
  _Times(BuildContext context, this.now)
    : _locale = Localizations.localeOf(context).toLanguageTag(),
      _never = context.l10n.liveDetailsNever;

  final DateTime now;
  final String _locale;
  final String _never;

  String at(DateTime t) {
    final local = t.toLocal();
    final today = now.toLocal();
    final sameDay =
        local.year == today.year &&
        local.month == today.month &&
        local.day == today.day;
    return sameDay
        ? DateFormat.Hms(_locale).format(local)
        : DateFormat.MMMd(_locale).add_Hms().format(local);
  }

  String maybe(DateTime? t) => t == null ? _never : at(t);
}
