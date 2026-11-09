// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'security.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in person's second factor: whether it is set up, and what
/// their tenant requires.
///
/// The authenticator secret and the recovery codes pass through as return
/// values and are never part of the state, so nothing keeps them once the
/// screen showing them is closed.

@ProviderFor(SecondFactor)
final secondFactorProvider = SecondFactorProvider._();

/// The signed-in person's second factor: whether it is set up, and what
/// their tenant requires.
///
/// The authenticator secret and the recovery codes pass through as return
/// values and are never part of the state, so nothing keeps them once the
/// screen showing them is closed.
final class SecondFactorProvider
    extends $AsyncNotifierProvider<SecondFactor, TOTPStatus> {
  /// The signed-in person's second factor: whether it is set up, and what
  /// their tenant requires.
  ///
  /// The authenticator secret and the recovery codes pass through as return
  /// values and are never part of the state, so nothing keeps them once the
  /// screen showing them is closed.
  SecondFactorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secondFactorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secondFactorHash();

  @$internal
  @override
  SecondFactor create() => SecondFactor();
}

String _$secondFactorHash() => r'bfa96e4e4610e7864f71e8a9febd9025215d6865';

/// The signed-in person's second factor: whether it is set up, and what
/// their tenant requires.
///
/// The authenticator secret and the recovery codes pass through as return
/// values and are never part of the state, so nothing keeps them once the
/// screen showing them is closed.

abstract class _$SecondFactor extends $AsyncNotifier<TOTPStatus> {
  FutureOr<TOTPStatus> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TOTPStatus>, TOTPStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TOTPStatus>, TOTPStatus>,
              AsyncValue<TOTPStatus>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The signed-in person's SSH keys, revoked ones included.

@ProviderFor(SshKeys)
final sshKeysProvider = SshKeysProvider._();

/// The signed-in person's SSH keys, revoked ones included.
final class SshKeysProvider
    extends $AsyncNotifierProvider<SshKeys, List<SSHKey>> {
  /// The signed-in person's SSH keys, revoked ones included.
  SshKeysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sshKeysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sshKeysHash();

  @$internal
  @override
  SshKeys create() => SshKeys();
}

String _$sshKeysHash() => r'0bf5aa42aeb871f40aa7ad7912e5bf40af11c882';

/// The signed-in person's SSH keys, revoked ones included.

abstract class _$SshKeys extends $AsyncNotifier<List<SSHKey>> {
  FutureOr<List<SSHKey>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<SSHKey>>, List<SSHKey>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SSHKey>>, List<SSHKey>>,
              AsyncValue<List<SSHKey>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The signed-in person's own sessions in this tenant, newest first, a page
/// at a time.

@ProviderFor(ActiveSessions)
final activeSessionsProvider = ActiveSessionsProvider._();

/// The signed-in person's own sessions in this tenant, newest first, a page
/// at a time.
final class ActiveSessionsProvider
    extends $AsyncNotifierProvider<ActiveSessions, Paged<SessionInfo>> {
  /// The signed-in person's own sessions in this tenant, newest first, a page
  /// at a time.
  ActiveSessionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeSessionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeSessionsHash();

  @$internal
  @override
  ActiveSessions create() => ActiveSessions();
}

String _$activeSessionsHash() => r'4dfa0548eda7b29716885ac9f8d18def26238361';

/// The signed-in person's own sessions in this tenant, newest first, a page
/// at a time.

abstract class _$ActiveSessions extends $AsyncNotifier<Paged<SessionInfo>> {
  FutureOr<Paged<SessionInfo>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<Paged<SessionInfo>>, Paged<SessionInfo>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Paged<SessionInfo>>, Paged<SessionInfo>>,
              AsyncValue<Paged<SessionInfo>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
