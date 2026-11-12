// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'connect_agent.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the Connect an agent screen fills every command in with, before a
/// token is issued: the server's address, the tenant and the version it
/// runs, which pins the install commands. Null when signed out.

@ProviderFor(connectTarget)
final connectTargetProvider = ConnectTargetProvider._();

/// What the Connect an agent screen fills every command in with, before a
/// token is issued: the server's address, the tenant and the version it
/// runs, which pins the install commands. Null when signed out.

final class ConnectTargetProvider
    extends
        $FunctionalProvider<
          AsyncValue<OnboardTarget?>,
          OnboardTarget?,
          FutureOr<OnboardTarget?>
        >
    with $FutureModifier<OnboardTarget?>, $FutureProvider<OnboardTarget?> {
  /// What the Connect an agent screen fills every command in with, before a
  /// token is issued: the server's address, the tenant and the version it
  /// runs, which pins the install commands. Null when signed out.
  ConnectTargetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectTargetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectTargetHash();

  @$internal
  @override
  $FutureProviderElement<OnboardTarget?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OnboardTarget?> create(Ref ref) {
    return connectTarget(ref);
  }
}

String _$connectTargetHash() => r'6382d43fb264b20ceb74fc15d73da0c5a04760b2';
