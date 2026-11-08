// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'status.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The installation's health and the tenant's work, as `tix status` reports
/// them: the last answer at once, then the server's.

@ProviderFor(StatusReportState)
final statusReportStateProvider = StatusReportStateProvider._();

/// The installation's health and the tenant's work, as `tix status` reports
/// them: the last answer at once, then the server's.
final class StatusReportStateProvider
    extends $AsyncNotifierProvider<StatusReportState, StatusReport> {
  /// The installation's health and the tenant's work, as `tix status` reports
  /// them: the last answer at once, then the server's.
  StatusReportStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'statusReportStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$statusReportStateHash();

  @$internal
  @override
  StatusReportState create() => StatusReportState();
}

String _$statusReportStateHash() => r'49969fcde336be3cba9cf80de4fbcb779f2536d8';

/// The installation's health and the tenant's work, as `tix status` reports
/// them: the last answer at once, then the server's.

abstract class _$StatusReportState extends $AsyncNotifier<StatusReport> {
  FutureOr<StatusReport> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<StatusReport>, StatusReport>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<StatusReport>, StatusReport>,
              AsyncValue<StatusReport>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
