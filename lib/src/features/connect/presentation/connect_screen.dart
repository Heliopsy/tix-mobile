// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/files.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/core/session/local.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/widgets/tix_mark.dart';
import 'package:tix_mobile/src/data/local/local_engine.dart';
import 'package:tix_mobile/src/data/models/instance.dart';
import 'package:tix_mobile/src/data/models/membership.dart';
import 'package:tix_mobile/src/features/connect/application/connect_flow.dart';

/// How a remote connection proves who it is.
enum ConnectMethod {
  /// An API token.
  token,

  /// Email and password.
  signIn,
}

/// Add an instance, or a connection to one: a server address or a database
/// file, then a token, a sign-in or a tenant.
class ConnectScreen extends ConsumerStatefulWidget {
  /// Creates the screen; [adding] when another instance is already active.
  const ConnectScreen({
    this.adding = false,
    this.instanceId,
    this.connectionId,
    this.url = '',
    this.email = '',
    super.key,
  });

  /// Whether this adds beside the active context, which gives the screen a
  /// way back.
  final bool adding;

  /// The saved instance a connection is added to.
  final String? instanceId;

  /// The sign-in connection to sign in again.
  final String? connectionId;

  /// An address to start from.
  final String url;

  /// An email to sign in with.
  final String email;

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  late final _url = TextEditingController(text: widget.url);
  final _token = TextEditingController();
  late final _email = TextEditingController(text: widget.email);
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _dbName = TextEditingController();
  final _tenantKey = TextEditingController();
  final _tenantName = TextEditingController();
  InstanceKind _kind = InstanceKind.remote;
  late ConnectMethod _method = widget.email.isNotEmpty || _replacing != null
      ? ConnectMethod.signIn
      : ConnectMethod.token;
  bool _busy = false;
  bool _showSecret = false;
  bool _pinned = false;
  String? _tenant;
  Object? _error;

  String? get _replacing => widget.connectionId;

  ConnectFlowProvider get _provider => connectFlowProvider(
    [
      widget.adding,
      widget.instanceId,
      widget.connectionId,
      widget.url,
      widget.email,
    ].join('|'),
  );

  @override
  void initState() {
    super.initState();
    final repo = ref.read(instancesRepositoryProvider);
    final old = repo.connection(widget.connectionId ?? '');
    if (old != null) _email.text = old.email;
    final saved = repo.instance(widget.instanceId ?? '');
    if (saved != null) _kind = saved.kind;
  }

  @override
  void dispose() {
    for (final c in [
      _url,
      _token,
      _email,
      _password,
      _name,
      _code,
      _dbName,
      _tenantKey,
      _tenantName,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  ConnectFlow get _flow => ref.read(_provider.notifier);

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (!mounted) return;
      if (ref.read(_provider) is ConnectDone && widget.adding) {
        context.go(Routes.projects);
      }
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submitRemote() => _run(
    () => _method == ConnectMethod.token
        ? _flow.token(
            url: _url.text,
            token: _token.text,
            name: _name.text,
            instanceId: widget.instanceId,
          )
        : _flow.signIn(
            url: _url.text,
            email: _email.text,
            password: _password.text,
            name: _name.text,
            instanceId: widget.instanceId,
            replacing: _replacing,
          ),
  );

  Future<void> _openFile() async {
    final files = ref.read(filePickingProvider);
    final path = files.opensInPlace
        ? await files.openDatabase()
        : await files.importDatabase();
    if (path == null) return;
    await _run(() => _flow.openLocal(path: path, name: _name.text));
  }

  Future<void> _newFile() async {
    final files = ref.read(filePickingProvider);
    final path = files.opensInPlace
        ? await files.newDatabase(_dbName.text)
        : await files.documentsDatabase(_dbName.text);
    if (path == null) return;
    await _run(
      () => _flow.openLocal(path: path, create: true, name: _name.text),
    );
  }

  void _back() {
    final step = ref.read(_provider);
    if (step is! ConnectForm && step is! ConnectDone) {
      setState(() => _error = null);
      _code.clear();
      _flow.restart().ignore();
      return;
    }
    context.go(
      widget.instanceId != null || widget.connectionId != null
          ? Routes.instances
          : Routes.settings,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final step = ref.watch(_provider);
    final error = _error;
    final repo = ref.read(instancesRepositoryProvider);
    final saved = repo.instance(
      widget.instanceId ??
          repo.connection(widget.connectionId ?? '')?.instanceId ??
          '',
    );
    final canGoBack = widget.adding || step is! ConnectForm;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          saved != null
              ? saved.name
              : widget.adding
              ? l10n.connectAddTitle
              : l10n.connectTitle,
        ),
        leading: canGoBack ? BackButton(onPressed: _back) : null,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: AutofillGroup(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...switch (step) {
                      ConnectForm() || ConnectDone() => _form(context, saved),
                      ConnectCode() => _codeStep(context),
                      ConnectTenants() => _tenantStep(context, step),
                      LocalTenants() => _localStep(context, step),
                    },
                    if (error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        errorMessage(l10n, error),
                        key: const Key('connect.error'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _spinnerOr(String label) => _busy
      ? const SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : Text(label);

  List<Widget> _form(BuildContext context, Instance? saved) {
    final l10n = context.l10n;
    final localEnabled = ref.watch(localInstancesEnabledProvider);
    return [
      if (saved == null) ...[
        const Center(child: TixMark()),
        const SizedBox(height: 24),
        Text(l10n.connectIntro),
        const SizedBox(height: 24),
        SegmentedButton<InstanceKind>(
          key: const Key('connect.kind'),
          segments: [
            ButtonSegment(
              value: InstanceKind.remote,
              label: Text(l10n.instanceRemote),
              icon: const Icon(Icons.cloud_outlined),
            ),
            ButtonSegment(
              value: InstanceKind.local,
              label: Text(l10n.instanceLocal),
              icon: const Icon(Icons.storage_outlined),
              enabled: localEnabled,
            ),
          ],
          selected: {_kind},
          onSelectionChanged: _busy
              ? null
              : (s) => setState(() {
                  _kind = s.first;
                  _error = null;
                }),
        ),
        if (!localEnabled) ...[
          const SizedBox(height: 8),
          Text(
            l10n.localUnavailableNote,
            key: const Key('connect.localNote'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 24),
      ],
      ...switch (_kind) {
        InstanceKind.remote => _remoteForm(context, saved),
        InstanceKind.local => _localForm(context, saved),
      },
    ];
  }

  List<Widget> _remoteForm(BuildContext context, Instance? saved) {
    final l10n = context.l10n;
    final reauth = _replacing != null;
    return [
      if (saved == null)
        TextField(
          key: const Key('connect.url'),
          controller: _url,
          enabled: !_busy,
          keyboardType: TextInputType.url,
          autofillHints: const [AutofillHints.url],
          autocorrect: false,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n.serverUrlLabel,
            hintText: l10n.serverUrlHint,
            border: const OutlineInputBorder(),
          ),
        )
      else
        Text(saved.baseUrl, key: const Key('connect.instanceUrl')),
      const SizedBox(height: 16),
      if (!reauth) ...[
        SegmentedButton<ConnectMethod>(
          key: const Key('connect.method'),
          segments: [
            ButtonSegment(
              value: ConnectMethod.token,
              label: Text(l10n.methodToken),
              icon: const Icon(Icons.key),
            ),
            ButtonSegment(
              value: ConnectMethod.signIn,
              label: Text(l10n.methodSignIn),
              icon: const Icon(Icons.person_outline),
            ),
          ],
          selected: {_method},
          onSelectionChanged: _busy
              ? null
              : (s) => setState(() {
                  _method = s.first;
                  _error = null;
                }),
        ),
        const SizedBox(height: 16),
      ],
      if (_method == ConnectMethod.token)
        _SecretField(
          fieldKey: const Key('connect.token'),
          controller: _token,
          enabled: !_busy,
          label: l10n.tokenLabel,
          helper: l10n.tokenHelp,
          visible: _showSecret,
          onToggle: () => setState(() => _showSecret = !_showSecret),
        )
      else ...[
        TextField(
          key: const Key('connect.email'),
          controller: _email,
          enabled: !_busy,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          autocorrect: false,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n.emailLabel,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        _SecretField(
          fieldKey: const Key('connect.password'),
          controller: _password,
          enabled: !_busy,
          label: l10n.passwordLabel,
          helper: l10n.signInHelp,
          visible: _showSecret,
          onToggle: () => setState(() => _showSecret = !_showSecret),
        ),
      ],
      if (saved == null) ...[
        const SizedBox(height: 16),
        _NameField(
          controller: _name,
          enabled: !_busy,
          onSubmitted: _busy ? null : _submitRemote,
        ),
      ],
      const SizedBox(height: 24),
      FilledButton(
        key: const Key('connect.submit'),
        onPressed: _busy ? null : _submitRemote,
        child: _spinnerOr(
          _method == ConnectMethod.token
              ? l10n.connectButton
              : l10n.signInButton,
        ),
      ),
    ];
  }

  List<Widget> _localForm(BuildContext context, Instance? saved) {
    final l10n = context.l10n;
    if (saved != null) {
      return [
        Text(saved.dbPath, key: const Key('connect.instancePath')),
        const SizedBox(height: 24),
        FilledButton(
          key: const Key('connect.openSaved'),
          onPressed: _busy
              ? null
              : () => _run(() => _flow.openLocal(instanceId: saved.id)),
          child: _spinnerOr(l10n.localListTenants),
        ),
      ];
    }
    final desktop = ref.watch(filePickingProvider).opensInPlace;
    return [
      Text(desktop ? l10n.localIntro : l10n.localIntroImport),
      const SizedBox(height: 16),
      _NameField(controller: _name, enabled: !_busy),
      const SizedBox(height: 24),
      if (!desktop) ...[
        TextField(
          key: const Key('connect.dbName'),
          controller: _dbName,
          enabled: !_busy,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: l10n.dbNameLabel,
            helperText: l10n.dbNameHelp,
            suffixText: '.db',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
      ],
      FilledButton.icon(
        key: const Key('connect.newDb'),
        onPressed: _busy ? null : _newFile,
        icon: const Icon(Icons.add),
        label: Text(desktop ? l10n.localNewFile : l10n.localCreate),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        key: const Key('connect.openDb'),
        onPressed: _busy ? null : _openFile,
        icon: Icon(desktop ? Icons.folder_open : Icons.file_download_outlined),
        label: Text(desktop ? l10n.localOpenFile : l10n.localImportFile),
      ),
      if (desktop) ...[
        const SizedBox(height: 8),
        Text(
          l10n.localOpenInPlace,
          key: const Key('connect.inPlaceNote'),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ];
  }

  List<Widget> _codeStep(BuildContext context) {
    final l10n = context.l10n;
    return [
      Text(l10n.codeIntro),
      const SizedBox(height: 16),
      TextField(
        key: const Key('connect.code'),
        controller: _code,
        enabled: !_busy,
        autofocus: true,
        keyboardType: TextInputType.number,
        autofillHints: const [AutofillHints.oneTimeCode],
        autocorrect: false,
        onSubmitted: (_) => _busy ? null : _run(() => _flow.code(_code.text)),
        decoration: InputDecoration(
          labelText: l10n.codeLabel,
          helperText: l10n.codeHelp,
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 24),
      FilledButton(
        key: const Key('connect.verify'),
        onPressed: _busy ? null : () => _run(() => _flow.code(_code.text)),
        child: _spinnerOr(l10n.verifyButton),
      ),
    ];
  }

  List<Widget> _tenantStep(BuildContext context, ConnectTenants step) {
    final l10n = context.l10n;
    final base = Uri.parse(step.draft.baseUrl);
    final here = [
      for (final m in step.me.memberships)
        if (!m.servedElsewhere(base.host)) m,
    ];
    final elsewhere = [
      for (final m in step.me.memberships)
        if (m.servedElsewhere(base.host)) m,
    ];
    final chosen = _tenant ?? step.me.tenantKey;
    final selected = here.where((m) => m.tenantKey == chosen).firstOrNull;
    return [
      Text(l10n.chooseTenantIntro),
      const SizedBox(height: 8),
      for (final m in here)
        ListTile(
          key: Key('connect.tenant.${m.tenantKey}'),
          leading: Icon(
            m.tenantKey == chosen
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
          ),
          title: Text(m.tenantName.isEmpty ? m.tenantKey : m.tenantName),
          subtitle: Text('${m.tenantKey} · @${m.handle} · ${m.role}'),
          selected: m.tenantKey == chosen,
          onTap: _busy ? null : () => setState(() => _tenant = m.tenantKey),
        ),
      for (final m in elsewhere)
        _ElsewhereTile(
          membership: m,
          onAdd: () => context.go(
            Routes.addInstanceAt(
              '${base.scheme}://${m.host}',
              email: step.draft.email,
            ),
          ),
        ),
      const SizedBox(height: 8),
      SwitchListTile(
        key: const Key('connect.pin'),
        value: _pinned,
        onChanged: _busy ? null : (v) => setState(() => _pinned = v),
        title: Text(l10n.pinLabel),
        subtitle: Text(_pinned ? l10n.pinOnHelp : l10n.pinOffHelp),
      ),
      const SizedBox(height: 24),
      FilledButton(
        key: const Key('connect.openTenant'),
        onPressed: _busy || selected == null
            ? null
            : () => _run(() => _flow.chooseTenant(selected, pinned: _pinned)),
        child: _spinnerOr(l10n.openButton),
      ),
    ];
  }

  List<Widget> _localStep(BuildContext context, LocalTenants step) {
    final l10n = context.l10n;
    return [
      Text(step.dbPath, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 16),
      Text(l10n.localTenantsIntro),
      const SizedBox(height: 8),
      for (final TenantRef t in step.tenants)
        ListTile(
          key: Key('connect.localTenant.${t.key}'),
          leading: const Icon(Icons.workspaces_outline),
          title: Text(t.name),
          subtitle: Text(t.key),
          trailing: const Icon(Icons.chevron_right),
          onTap: _busy ? null : () => _run(() => _flow.openLocalTenant(t)),
        ),
      const SizedBox(height: 24),
      Text(l10n.newTenantTitle, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 12),
      TextField(
        key: const Key('connect.tenantKey'),
        controller: _tenantKey,
        enabled: !_busy,
        autocorrect: false,
        decoration: InputDecoration(
          labelText: l10n.tenantKeyLabel,
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        key: const Key('connect.tenantName'),
        controller: _tenantName,
        enabled: !_busy,
        decoration: InputDecoration(
          labelText: l10n.tenantNameLabel,
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      FilledButton.tonal(
        key: const Key('connect.createTenant'),
        onPressed: _busy
            ? null
            : () => _run(
                () => _flow.createLocalTenant(
                  key: _tenantKey.text,
                  name: _tenantName.text,
                ),
              ),
        child: _spinnerOr(l10n.createTenantButton),
      ),
    ];
  }
}

class _SecretField extends StatelessWidget {
  const _SecretField({
    required this.fieldKey,
    required this.controller,
    required this.enabled,
    required this.label,
    required this.helper,
    required this.visible,
    required this.onToggle,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final bool enabled;
  final String label;
  final String helper;
  final bool visible;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => TextField(
    key: fieldKey,
    controller: controller,
    enabled: enabled,
    obscureText: !visible,
    autocorrect: false,
    enableSuggestions: false,
    autofillHints: const [AutofillHints.password],
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(
      labelText: label,
      helperText: helper,
      helperMaxLines: 3,
      border: const OutlineInputBorder(),
      suffixIcon: IconButton(
        icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
        onPressed: onToggle,
      ),
    ),
  );
}

class _NameField extends StatelessWidget {
  const _NameField({
    required this.controller,
    required this.enabled,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final submit = onSubmitted;
    return TextField(
      key: const Key('connect.name'),
      controller: controller,
      enabled: enabled,
      textInputAction: TextInputAction.done,
      onSubmitted: submit == null ? null : (_) => submit(),
      decoration: InputDecoration(
        labelText: l10n.contextNameLabel,
        helperText: l10n.contextNameHelp,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _ElsewhereTile extends StatelessWidget {
  const _ElsewhereTile({required this.membership, required this.onAdd});

  final Membership membership;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final m = membership;
    return ListTile(
      key: Key('connect.elsewhere.${m.tenantKey}'),
      leading: const Icon(Icons.open_in_new),
      title: Text(m.tenantName.isEmpty ? m.tenantKey : m.tenantName),
      subtitle: Text(l10n.servedAt(m.host)),
      trailing: TextButton(onPressed: onAdd, child: Text(l10n.addAsInstance)),
    );
  }
}
