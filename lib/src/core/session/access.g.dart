// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'access.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the active credential may do: the last `whoami` kept for the
/// context at once, then the server's answer.

@ProviderFor(CurrentAccess)
final currentAccessProvider = CurrentAccessProvider._();

/// What the active credential may do: the last `whoami` kept for the
/// context at once, then the server's answer.
final class CurrentAccessProvider
    extends $AsyncNotifierProvider<CurrentAccess, Access> {
  /// What the active credential may do: the last `whoami` kept for the
  /// context at once, then the server's answer.
  CurrentAccessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentAccessProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentAccessHash();

  @$internal
  @override
  CurrentAccess create() => CurrentAccess();
}

String _$currentAccessHash() => r'9953f7233d06ead24279b3937f9499c86e0d69ed';

/// What the active credential may do: the last `whoami` kept for the
/// context at once, then the server's answer.

abstract class _$CurrentAccess extends $AsyncNotifier<Access> {
  FutureOr<Access> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Access>, Access>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Access>, Access>,
              AsyncValue<Access>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
