// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/session/admin.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/core/widgets/form_sheet.dart';
import 'package:tix_mobile/src/features/admin/application/tenant_admin.dart';

/// The hostnames that resolve to the active tenant: add one, with how it
/// gets its certificate, or remove one.
class DomainsScreen extends ConsumerWidget {
  /// Creates the screen.
  const DomainsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final add = TixAction(
      key: const Key('domains.add'),
      label: l10n.domainAdd,
      icon: Icons.add,
      onPressed: () => _add(context),
    );
    return TixPage(
      title: l10n.domainsTitle,
      subtitle: l10n.domainsSubtitle,
      primaryAction: add,
      body: AsyncBody(
        value: ref.watch(tenantDomainListProvider),
        onRetry: () => ref.invalidate(tenantDomainListProvider),
        data: (domains) => RefreshIndicator(
          onRefresh: () => ref.refresh(tenantDomainListProvider.future),
          child: domains.isEmpty
              ? ListView(
                  children: [
                    EmptyState(
                      icon: Icons.language,
                      title: l10n.domainsEmpty,
                      body: l10n.domainsEmptyBody,
                      action: add,
                    ),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: TixSpace.s7 * 2),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(TixSpace.s4),
                      child: Text(
                        l10n.domainsBody,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    for (final d in domains) DomainRow(domain: d),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _add(BuildContext context) async {
    final added = await showTixSheet<Object>(
      context,
      builder: (_) => const _DomainForm(),
    );
    if (added != null && added != false && context.mounted) {
      showTixToast(context, context.l10n.domainAdded);
    }
  }
}

/// One hostname: how it gets its certificate, whether it is verified and
/// shared, and Remove.
class DomainRow extends ConsumerWidget {
  /// Draws [domain].
  const DomainRow({required this.domain, this.trailing, super.key});

  /// The domain.
  final Domain domain;

  /// Replaces the Remove button, as the tenant tree's shared switch does.
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ListTile(
      key: Key('domain.${domain.hostname}'),
      leading: const Icon(Icons.language),
      title: Text(domain.hostname, style: tixMono(context, size: TixText.md)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: TixSpace.s1),
        child: Wrap(
          spacing: TixSpace.s2,
          runSpacing: TixSpace.s1,
          children: [
            TixBadge(
              domain.certMode == 'file'
                  ? l10n.domainCertFile
                  : l10n.domainCertNone,
            ),
            if (domain.verifiedAt != null)
              TixBadge(l10n.domainVerified, tone: TixTone.ok),
            if (domain.shared)
              TixBadge(l10n.domainShared, tone: TixTone.accent),
          ],
        ),
      ),
      trailing:
          trailing ??
          TixButton.danger(
            key: Key('domain.remove.${domain.hostname}'),
            label: l10n.remove,
            size: TixButtonSize.small,
            onPressed: () => _remove(context, ref),
          ),
    );
  }

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.domainRemove,
      body: l10n.domainRemoveBody(domain.hostname),
      action: l10n.remove,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(tenantDomainListProvider.notifier).remove(domain.hostname);
      if (context.mounted) showTixToast(context, l10n.domainRemoved);
    } on Object catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }
}

class _DomainForm extends ConsumerStatefulWidget {
  const _DomainForm();

  @override
  ConsumerState<_DomainForm> createState() => _DomainFormState();
}

class _DomainFormState extends ConsumerState<_DomainForm> {
  final _host = TextEditingController();
  final _cert = TextEditingController();
  final _key = TextEditingController();
  var _mode = 'none';

  @override
  void dispose() {
    _host.dispose();
    _cert.dispose();
    _key.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final file = _mode == 'file';
    return FormSheet(
      title: l10n.domainAdd,
      submitLabel: l10n.domainAddSubmit,
      onSubmit: () => ref
          .read(tenantDomainListProvider.notifier)
          .add(
            AddDomainInput(
              hostname: _host.text.trim(),
              certMode: _mode,
              certPath: file ? _cert.text.trim() : null,
              keyPath: file ? _key.text.trim() : null,
            ),
          ),
      children: [
        TixTextField(
          fieldKey: const Key('domain.hostname'),
          label: l10n.domainHostname,
          hint: 'tix.example.com',
          help: l10n.domainHostnameHelp,
          controller: _host,
          keyboardType: TextInputType.url,
        ),
        formGap,
        Text(
          l10n.domainCertMode,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: TixSpace.s2),
        SegmentedButton<String>(
          key: const Key('domain.certMode'),
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: 'none', label: Text(l10n.domainCertNone)),
            ButtonSegment(value: 'file', label: Text(l10n.domainCertFile)),
          ],
          selected: {_mode},
          onSelectionChanged: (s) => setState(() => _mode = s.first),
        ),
        const SizedBox(height: TixSpace.s1),
        Text(
          file ? l10n.domainCertFileHelp : l10n.domainCertNoneHelp,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (file) ...[
          formGap,
          TixTextField(
            fieldKey: const Key('domain.certPath'),
            label: l10n.domainCertPath,
            hint: '/etc/tix/tls/tix.example.com.crt',
            controller: _cert,
          ),
          formGap,
          TixTextField(
            fieldKey: const Key('domain.keyPath'),
            label: l10n.domainKeyPath,
            hint: '/etc/tix/tls/tix.example.com.key',
            controller: _key,
          ),
        ],
      ],
    );
  }
}
