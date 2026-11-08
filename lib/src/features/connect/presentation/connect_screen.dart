// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/features/connect/application/session.dart';

/// Sign in to a tix server with its address and an API token.
class ConnectScreen extends ConsumerStatefulWidget {
  /// Creates the screen; [adding] when another server is already active.
  const ConnectScreen({this.adding = false, super.key});

  /// Whether this adds a server beside the active one, which gives the
  /// screen a way back.
  final bool adding;

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  final _url = TextEditingController();
  final _token = TextEditingController();
  final _name = TextEditingController();
  bool _busy = false;
  bool _showToken = false;
  Object? _error;

  @override
  void dispose() {
    _url.dispose();
    _token.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .connect(url: _url.text, token: _token.text, name: _name.text);
      if (mounted && widget.adding) context.go(Routes.projects);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = _error;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.adding ? l10n.connectAddTitle : l10n.connectTitle),
        leading: widget.adding
            ? BackButton(onPressed: () => context.go(Routes.settings))
            : null,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: AutofillGroup(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(l10n.connectIntro),
                  const SizedBox(height: 24),
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
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('connect.token'),
                    controller: _token,
                    enabled: !_busy,
                    obscureText: !_showToken,
                    autocorrect: false,
                    enableSuggestions: false,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.tokenLabel,
                      helperText: l10n.tokenHelp,
                      helperMaxLines: 2,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showToken ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _showToken = !_showToken),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('connect.name'),
                    controller: _name,
                    enabled: !_busy,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _busy ? null : _connect(),
                    decoration: InputDecoration(
                      labelText: l10n.contextNameLabel,
                      helperText: l10n.contextNameHelp,
                      border: const OutlineInputBorder(),
                    ),
                  ),
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
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('connect.submit'),
                    onPressed: _busy ? null : _connect,
                    child: _busy
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.connectButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
