// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'dav.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The state of CalDAV for the active context, asked once per visit. A
/// local instance sends nothing.

@ProviderFor(davStatus)
final davStatusProvider = DavStatusProvider._();

/// The state of CalDAV for the active context, asked once per visit. A
/// local instance sends nothing.

final class DavStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<DavStatus>,
          DavStatus,
          FutureOr<DavStatus>
        >
    with $FutureModifier<DavStatus>, $FutureProvider<DavStatus> {
  /// The state of CalDAV for the active context, asked once per visit. A
  /// local instance sends nothing.
  DavStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'davStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$davStatusHash();

  @$internal
  @override
  $FutureProviderElement<DavStatus> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DavStatus> create(Ref ref) {
    return davStatus(ref);
  }
}

String _$davStatusHash() => r'9139f2e657ec8e374f907b415ee7338ff0bf4ac4';

/// The caller's app passwords, live ones first, newest first.
///
/// Values never pass through here: a listing carries none, and an issued
/// password goes straight back to the sheet that hands it off.

@ProviderFor(AppPasswords)
final appPasswordsProvider = AppPasswordsProvider._();

/// The caller's app passwords, live ones first, newest first.
///
/// Values never pass through here: a listing carries none, and an issued
/// password goes straight back to the sheet that hands it off.
final class AppPasswordsProvider
    extends $AsyncNotifierProvider<AppPasswords, List<DavPassword>> {
  /// The caller's app passwords, live ones first, newest first.
  ///
  /// Values never pass through here: a listing carries none, and an issued
  /// password goes straight back to the sheet that hands it off.
  AppPasswordsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appPasswordsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appPasswordsHash();

  @$internal
  @override
  AppPasswords create() => AppPasswords();
}

String _$appPasswordsHash() => r'0afc5ce3ca57ba5661446e83356645b2c013e3a3';

/// The caller's app passwords, live ones first, newest first.
///
/// Values never pass through here: a listing carries none, and an issued
/// password goes straight back to the sheet that hands it off.

abstract class _$AppPasswords extends $AsyncNotifier<List<DavPassword>> {
  FutureOr<List<DavPassword>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<DavPassword>>, List<DavPassword>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<DavPassword>>, List<DavPassword>>,
              AsyncValue<List<DavPassword>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
