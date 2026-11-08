// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'commands.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's command registry. Features add to it with [CommandScope].

@ProviderFor(commandRegistry)
final commandRegistryProvider = CommandRegistryProvider._();

/// The app's command registry. Features add to it with [CommandScope].

final class CommandRegistryProvider
    extends
        $FunctionalProvider<CommandRegistry, CommandRegistry, CommandRegistry>
    with $Provider<CommandRegistry> {
  /// The app's command registry. Features add to it with [CommandScope].
  CommandRegistryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commandRegistryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commandRegistryHash();

  @$internal
  @override
  $ProviderElement<CommandRegistry> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CommandRegistry create(Ref ref) {
    return commandRegistry(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CommandRegistry value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CommandRegistry>(value),
    );
  }
}

String _$commandRegistryHash() => r'4cd054338bd2ebf82d8d94fc3662f6f6199e0756';
