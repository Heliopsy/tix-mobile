// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/app_info.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart';
import 'package:tix_mobile/src/core/widgets/tix_mark.dart';
import 'package:tix_mobile/src/features/about/application/about.dart';

/// What the app is, which versions run, where the project lives and how to
/// report a bug.
class AboutScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  bool _withServer = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final app = ref.watch(appInfoProvider);
    final engine = ref.watch(engineVersionProvider);
    final server = ref.watch(serverVersionProvider);
    final address = ref.watch(serverAddressProvider);
    final diagnostics = switch (app.value) {
      final a? => Diagnostics(
        app: a,
        engine: engine.value,
        server: server.value,
        serverAddress: address,
        locale: Localizations.localeOf(context).toLanguageTag(),
      ),
      null => null,
    };
    Widget version(
      AsyncValue<String?> v,
      String none,
      String failed,
      String id,
    ) => switch (v) {
      AsyncData(:final value) => Text(value ?? none, key: Key(id)),
      AsyncError() => Text(failed, key: Key(id)),
      _ => const Align(
        alignment: AlignmentDirectional.centerStart,
        child: SkeletonBox(width: TixSpace.s7),
      ),
    };
    return TixPage(
      title: l10n.aboutTitle,
      body: ListView(
        padding: const EdgeInsets.only(bottom: TixSpace.s6),
        children: [
          Padding(
            padding: const EdgeInsets.all(TixSpace.gutter),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: TixMeasure.text),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const TixMark(size: TixSize.target),
                      const SizedBox(width: TixSpace.s4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.appTitle,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              l10n.aboutTagline,
                              style: TextStyle(color: t.muted),
                            ),
                            if (diagnostics != null)
                              Text(
                                l10n.aboutVersion(diagnostics.appVersion),
                                key: const Key('about.version'),
                                style: TextStyle(
                                  color: t.muted,
                                  fontSize: TixText.sm,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: TixSpace.s4),
                  Text(l10n.aboutIntro),
                ],
              ),
            ),
          ),
          TixSection(
            title: l10n.aboutVersions,
            children: [
              Padding(
                padding: const EdgeInsets.all(TixSpace.s3),
                child: TixPropertyList(
                  children: [
                    TixPropertyRow(
                      label: l10n.aboutAppVersion,
                      child: version(
                        app.whenData((a) => diagnostics?.appVersion),
                        '',
                        l10n.aboutServerUnknown,
                        'about.app',
                      ),
                    ),
                    TixPropertyRow(
                      label: l10n.aboutEngineVersion,
                      child: version(
                        engine,
                        l10n.aboutEngineNone,
                        l10n.aboutEngineNone,
                        'about.engine',
                      ),
                    ),
                    TixPropertyRow(
                      label: l10n.aboutServerVersion,
                      child: version(
                        server,
                        l10n.aboutServerNone,
                        l10n.aboutServerUnknown,
                        'about.server',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          TixSection(
            title: l10n.aboutHelp,
            children: [
              Padding(
                padding: const EdgeInsets.all(TixSpace.s3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aboutReportBugHelp,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: TixSpace.s3),
                    Wrap(
                      spacing: TixSpace.s3,
                      runSpacing: TixSpace.s2,
                      children: [
                        TixButton(
                          key: const Key('about.bug'),
                          label: l10n.aboutReportBug,
                          icon: Icons.bug_report_outlined,
                          onPressed: diagnostics == null
                              ? null
                              : () => _open(diagnostics.bugReport()),
                        ),
                        TixButton.quiet(
                          key: const Key('about.copy'),
                          label: l10n.aboutCopyDiagnostics,
                          icon: Icons.copy_outlined,
                          onPressed: diagnostics == null
                              ? null
                              : () => _copy(diagnostics),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (address.isNotEmpty)
                TixSwitchRow(
                  key: const Key('about.withServer'),
                  title: l10n.aboutIncludeServer,
                  subtitle: l10n.aboutIncludeServerHelp,
                  value: _withServer,
                  onChanged: (v) => setState(() => _withServer = v),
                ),
            ],
          ),
          TixSection(
            title: l10n.aboutLinks,
            children: [
              _Link(
                id: 'website',
                icon: Icons.public,
                title: l10n.aboutWebsite,
                subtitle: AboutLinks.website.host,
                onTap: () => _open(AboutLinks.website),
              ),
              _Link(
                id: 'source',
                icon: Icons.code,
                title: l10n.aboutSource,
                subtitle: l10n.aboutSourceHelp,
                onTap: () => _open(AboutLinks.source),
              ),
              _Link(
                id: 'roadmap',
                icon: Icons.map_outlined,
                title: l10n.aboutRoadmap,
                subtitle: l10n.aboutRoadmapHelp,
                onTap: () => _open(AboutLinks.roadmap),
              ),
              _Link(
                id: 'changelog',
                icon: Icons.history,
                title: l10n.aboutChangelog,
                subtitle: l10n.aboutChangelogHelp,
                onTap: () => _open(AboutLinks.changelog),
              ),
              _Link(
                id: 'server',
                icon: Icons.dns_outlined,
                title: l10n.aboutServerProject,
                subtitle: l10n.aboutServerProjectHelp,
                onTap: () => _open(AboutLinks.server),
              ),
              _Link(
                id: 'security',
                icon: Icons.shield_outlined,
                title: l10n.aboutSecurity,
                subtitle: l10n.aboutSecurityHelp,
                onTap: () => _open(AboutLinks.security),
              ),
            ],
          ),
          TixSection(
            title: l10n.aboutLicence,
            children: [
              Padding(
                padding: const EdgeInsets.all(TixSpace.s3),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: TixMeasure.text),
                  child: Text(l10n.aboutLicenceBody),
                ),
              ),
              ListTile(
                key: const Key('about.licences'),
                leading: const Icon(Icons.description_outlined),
                title: Text(l10n.aboutLicences),
                subtitle: Text(l10n.aboutLicencesHelp),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: l10n.appTitle,
                  applicationVersion: diagnostics?.appVersion,
                  applicationIcon: const TixMark(size: TixSize.target),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _open(Uri uri) async {
    final failed = context.l10n.aboutOpenFailed;
    final ok = await ref.read(attachmentsProvider).openLink(uri);
    if (!ok && mounted) showTixToast(context, failed, tone: TixTone.danger);
  }

  Future<void> _copy(Diagnostics d) async {
    final copied = context.l10n.aboutDiagnosticsCopied;
    await Clipboard.setData(
      ClipboardData(text: d.toText(withServerAddress: _withServer)),
    );
    if (mounted) showTixToast(context, copied);
  }
}

class _Link extends StatelessWidget {
  const _Link({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    key: Key('about.link.$id'),
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.open_in_new),
    onTap: onTap,
  );
}
