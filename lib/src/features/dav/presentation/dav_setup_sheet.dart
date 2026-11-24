// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart';
import 'package:tix_mobile/src/core/platform/dav_handoff.dart';
import 'package:tix_mobile/src/core/platform/sharing.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/dav/application/dav.dart';
import 'package:tix_mobile/src/features/dav/presentation/dav_details.dart';

/// How long a new app password lasts.
enum DavExpiry {
  /// Never, tix's default.
  never,

  /// 30 days.
  days30,

  /// 90 days.
  days90,

  /// A year.
  year,
}

/// When a password created at [now] with [expiry] stops, null for never.
DateTime? davExpiresAt(DavExpiry expiry, DateTime now) => switch (expiry) {
  DavExpiry.never => null,
  DavExpiry.days30 => now.add(const Duration(days: 30)),
  DavExpiry.days90 => now.add(const Duration(days: 90)),
  DavExpiry.year => now.add(const Duration(days: 365)),
};

/// The platform's name in a default password name.
String davPlatformName(DavPlatform p) => switch (p) {
  DavPlatform.ios => 'iOS',
  DavPlatform.macos => 'macOS',
  DavPlatform.android => 'Android',
  DavPlatform.linux => 'Linux',
  DavPlatform.windows => 'Windows',
  DavPlatform.other => 'desktop',
};

/// [day] as `yyyy-mm-dd`.
String isoDay(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';

/// Creates an app password and hands it to another app on this device.
/// The password lives in this sheet's state only; closing it, or switching
/// context, drops it. Pops true once a password was issued.
class DavSetupSheet extends ConsumerStatefulWidget {
  /// Sets up against [ready]; [replacing] is the read-only password this
  /// one replaces, whose lists it starts from.
  const DavSetupSheet({required this.ready, this.replacing, super.key});

  /// What the server answered.
  final DavReady ready;

  /// The password being replaced, if any.
  final DavPassword? replacing;

  @override
  ConsumerState<DavSetupSheet> createState() => _DavSetupSheetState();
}

class _DavSetupSheetState extends ConsumerState<DavSetupSheet> {
  final _name = TextEditingController();
  late final DavHandoff _handoff = ref.read(davHandoffProvider);
  late final Future<bool> _davx5 = _handoff.davx5Installed();
  late String _collections = _initialCollections();
  DavExpiry _expiry = DavExpiry.never;
  var _readOnly = false;
  var _busy = false;
  var _named = false;
  String? _error;
  IssuedDavPassword? _issued;
  bool? _served;
  var _openFailed = false;
  var _closed = false;

  List<String> get _choices => widget.ready.info.collections.isEmpty
      ? const [
          DavCollections.assigned,
          DavCollections.projects,
          DavCollections.all,
        ]
      : widget.ready.info.collections;

  String _initialCollections() {
    final from = widget.replacing?.collections;
    if (from != null && _choices.contains(from)) return from;
    return _choices.contains(DavCollections.assigned)
        ? DavCollections.assigned
        : _choices.first;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_named) return;
    _named = true;
    _name.text = context.l10n.davDefaultName(
      davPlatformName(_handoff.platform),
      isoDay(ref.read(clockProvider)()),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    unawaited(_handoff.cleanUp());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionControllerProvider.select((s) => s.value?.ref), (
      before,
      now,
    ) {
      if (before == now || _closed || !mounted) return;
      _closed = true;
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        Navigator.of(context).pop(false);
      }
    });
    final issued = _issued;
    return issued == null ? _form(context) : _handoffView(context, issued);
  }

  Widget _form(BuildContext context) {
    final l10n = context.l10n;
    final small = Theme.of(context).textTheme.bodySmall;
    return TixSheetBody(
      title: l10n.davSetUp,
      actions: [
        TixButton.quiet(
          key: const Key('dav.cancel'),
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TixButton.primary(
          key: const Key('dav.create'),
          label: l10n.davCreate,
          busy: _busy,
          onPressed: _busy ? null : _create,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TixTextField(
            label: l10n.davName,
            controller: _name,
            fieldKey: const Key('dav.name'),
            help: l10n.davNameHelp,
            error: _error,
          ),
          const SizedBox(height: TixSpace.s4),
          Text(l10n.davLists, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: TixSpace.s2),
          TixChoices<String>(
            key: const Key('dav.lists'),
            choices: [
              for (final c in _choices)
                TixChoice(c, davCollectionsLabel(l10n, c)),
            ],
            selected: _collections,
            onSelected: (c) => setState(() => _collections = c),
          ),
          const SizedBox(height: TixSpace.s1),
          Text(davCollectionsHelp(l10n, _collections), style: small),
          Text(l10n.davListsChangeHelp, style: small),
          const SizedBox(height: TixSpace.s4),
          Text(l10n.davExpiry, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: TixSpace.s2),
          TixChoices<DavExpiry>(
            key: const Key('dav.expiry'),
            choices: [
              TixChoice(DavExpiry.never, l10n.davExpiryNever),
              TixChoice(DavExpiry.days30, l10n.davExpiry30),
              TixChoice(DavExpiry.days90, l10n.davExpiry90),
              TixChoice(DavExpiry.year, l10n.davExpiryYear),
            ],
            selected: _expiry,
            onSelected: (e) => setState(() => _expiry = e),
          ),
          const SizedBox(height: TixSpace.s1),
          Text(l10n.davExpiryHelp, style: small),
          if (widget.ready.write) ...[
            const SizedBox(height: TixSpace.s3),
            TixSwitchRow(
              key: const Key('dav.readOnly'),
              title: l10n.davReadOnly,
              subtitle: l10n.davReadOnlyHelp,
              value: _readOnly,
              onChanged: (v) => setState(() => _readOnly = v),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _create() async {
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final issued = await ref
          .read(appPasswordsProvider.notifier)
          .create(
            name: _name.text,
            collections: _collections,
            readOnly: widget.ready.write && _readOnly ? true : null,
            expiresAt: davExpiresAt(_expiry, ref.read(clockProvider)()),
          );
      if (mounted) setState(() => _issued = issued);
    } on TixException catch (e) {
      if (!mounted) return;
      setState(
        () => _error = e.kind == TixErrorKind.conflict && e.message.isNotEmpty
            ? e.message
            : errorDetail(l10n, e),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  DavAccount _account(IssuedDavPassword issued) => DavAccount(
    url: issued.url.isNotEmpty ? issued.url : widget.ready.address,
    username: issued.username.isNotEmpty
        ? issued.username
        : widget.ready.info.username,
    password: issued.password,
  );

  String _profile(DavAccount account) {
    final l10n = context.l10n;
    final session = ref.read(sessionControllerProvider).value;
    final tenant = session?.connection.tenantName ?? '';
    final random = Random.secure();
    return buildCalDavProfile(
      account: account,
      connectionId: session?.connection.id ?? 'tix',
      text: DavProfileText(
        account: l10n.davProfileAccount(
          tenant.isNotEmpty ? tenant : session?.instance.name ?? 'tix',
        ),
        displayName: l10n.davProfileName,
        description: l10n.davProfileDescription,
      ),
      payloadUuid: randomUuid(random),
      profileUuid: randomUuid(random),
    );
  }

  Widget _handoffView(BuildContext context, IssuedDavPassword issued) {
    final l10n = context.l10n;
    final account = _account(issued);
    return TixSheetBody(
      title: l10n.davHandoffTitle,
      actions: [
        TixButton.primary(
          key: const Key('dav.done'),
          label: l10n.davDone,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TixNotice(l10n.davOnce, tone: TixNoticeTone.warn),
          const SizedBox(height: TixSpace.s3),
          ..._platformPart(context, account),
          if (_openFailed) ...[
            const SizedBox(height: TixSpace.s2),
            TixNotice(
              l10n.davOpenFailed,
              tone: TixNoticeTone.danger,
              key: const Key('dav.openFailed'),
            ),
          ],
          const SizedBox(height: TixSpace.s3),
          DavDetails(
            key: const Key('dav.details'),
            address: account.url,
            username: account.username,
            password: account.password,
          ),
        ],
      ),
    );
  }

  List<Widget> _platformPart(BuildContext context, DavAccount account) {
    final l10n = context.l10n;
    final small = Theme.of(context).textTheme.bodySmall;
    switch (_handoff.platform) {
      case DavPlatform.ios:
        return [
          _Steps([
            l10n.davIosStep1,
            l10n.davIosStep2,
            l10n.davIosStep3,
            l10n.davAppleStepLast,
          ]),
          Text(l10n.davIosUnsigned, style: small),
          const SizedBox(height: TixSpace.s1),
          Text(l10n.davIosLimits, style: small),
          const SizedBox(height: TixSpace.s3),
          Wrap(
            spacing: TixSpace.s2,
            runSpacing: TixSpace.s2,
            children: [
              TixButton(
                key: const Key('dav.openProfile'),
                label: l10n.davOpenSafari,
                icon: Icons.open_in_new,
                onPressed: () => _openProfile(account, l10n.davOpenedSafari),
              ),
              if (_served == false)
                Builder(
                  builder: (context) => TixButton(
                    key: const Key('dav.saveProfile'),
                    label: l10n.davSaveProfile,
                    icon: Icons.save_alt,
                    onPressed: () => _handoff.saveProfile(
                      _profile(account),
                      origin: originOf(context),
                    ),
                  ),
                ),
            ],
          ),
          if (_served == false) ...[
            const SizedBox(height: TixSpace.s2),
            TixNotice(l10n.davNotFetched, key: const Key('dav.notFetched')),
          ],
        ];
      case DavPlatform.macos:
        return [
          _Steps([l10n.davMacStep1, l10n.davMacStep2, l10n.davAppleStepLast]),
          Text(l10n.davMacUnsigned, style: small),
          const SizedBox(height: TixSpace.s3),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TixButton(
              key: const Key('dav.openProfile'),
              label: l10n.davOpenProfile,
              icon: Icons.open_in_new,
              onPressed: () => _openProfile(account, l10n.davOpenedSettings),
            ),
          ),
        ];
      case DavPlatform.android:
        return [
          FutureBuilder<bool>(
            future: _davx5,
            builder: (context, snap) {
              if (!snap.hasData) return const SizedBox.shrink();
              return snap.data!
                  ? _Davx5Open(onOpen: () => _openDavx5(account))
                  : _Davx5Missing(links: _handoff.storeLinks);
            },
          ),
        ];
      case DavPlatform.linux:
        return [
          Text(l10n.davThunderbirdSteps, style: small),
          const SizedBox(height: TixSpace.s2),
          Text(l10n.davEvolutionSteps, style: small),
        ];
      case DavPlatform.windows:
        return [
          Text(l10n.davWindowsNote, style: small),
          const SizedBox(height: TixSpace.s2),
          Text(l10n.davThunderbirdSteps, style: small),
        ];
      case DavPlatform.other:
        return const [];
    }
  }

  Future<void> _openProfile(DavAccount account, String done) async {
    final opening = await _handoff.openProfile(_profile(account));
    if (!mounted) return;
    setState(() => _openFailed = !opening.opened);
    if (!opening.opened) return;
    showTixToast(context, done);
    final served = await opening.served;
    if (mounted) setState(() => _served = served);
  }

  Future<void> _openDavx5(DavAccount account) async {
    final l10n = context.l10n;
    final opened = await _handoff.openDavx5(account);
    if (!mounted) return;
    setState(() => _openFailed = !opened);
    if (opened) showTixToast(context, l10n.davOpenedDavx5);
  }
}

/// The name of the collections choice [c], or [c] itself for one the app
/// has no words for.
String davCollectionsLabel(AppLocalizations l10n, String c) => switch (c) {
  DavCollections.assigned => l10n.davListsAssigned,
  DavCollections.projects => l10n.davListsProjects,
  DavCollections.all => l10n.davListsAll,
  _ => c,
};

/// What the collections choice [c] shows, empty for an unknown one.
String davCollectionsHelp(AppLocalizations l10n, String c) => switch (c) {
  DavCollections.assigned => l10n.davListsAssignedHelp,
  DavCollections.projects => l10n.davListsProjectsHelp,
  DavCollections.all => l10n.davListsAllHelp,
  _ => '',
};

class _Steps extends StatelessWidget {
  const _Steps(this.steps);

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.only(bottom: TixSpace.s2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, step) in steps.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: TixSpace.s1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: TixSpace.s5,
                    child: Text('${i + 1}.', style: style),
                  ),
                  Expanded(child: Text(step, style: style)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Davx5Open extends StatelessWidget {
  const _Davx5Open({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.davDavx5Body, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: TixSpace.s3),
        TixButton(
          key: const Key('dav.openDavx5'),
          label: l10n.davOpenDavx5,
          icon: Icons.open_in_new,
          onPressed: onOpen,
        ),
      ],
    );
  }
}

class _Davx5Missing extends ConsumerWidget {
  const _Davx5Missing({required this.links});

  final DavStoreLinks links;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final open = ref.read(attachmentsProvider).openLink;
    return Column(
      key: const Key('dav.noDavx5'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.davNoDavx5, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: TixSpace.s3),
        Wrap(
          spacing: TixSpace.s2,
          runSpacing: TixSpace.s2,
          children: [
            TixButton(
              key: const Key('dav.getDavx5'),
              label: l10n.davGetDavx5,
              icon: Icons.download_outlined,
              onPressed: () => open(links.davx5),
            ),
            TixButton(
              key: const Key('dav.getTasksOrg'),
              label: l10n.davGetTasksOrg,
              onPressed: () => open(links.tasksOrg),
            ),
            TixButton(
              key: const Key('dav.getJtx'),
              label: l10n.davGetJtx,
              onPressed: () => open(links.jtx),
            ),
          ],
        ),
      ],
    );
  }
}
