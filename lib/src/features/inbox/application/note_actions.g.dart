// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'note_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs notification actions with this engine's providers. In the app's
/// engine the outbox stores are the ones its sync uses, so a queued action
/// is sent with the rest.

@ProviderFor(noteActionRunner)
final noteActionRunnerProvider = NoteActionRunnerProvider._();

/// Runs notification actions with this engine's providers. In the app's
/// engine the outbox stores are the ones its sync uses, so a queued action
/// is sent with the rest.

final class NoteActionRunnerProvider
    extends
        $FunctionalProvider<
          NoteActionRunner,
          NoteActionRunner,
          NoteActionRunner
        >
    with $Provider<NoteActionRunner> {
  /// Runs notification actions with this engine's providers. In the app's
  /// engine the outbox stores are the ones its sync uses, so a queued action
  /// is sent with the rest.
  NoteActionRunnerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteActionRunnerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteActionRunnerHash();

  @$internal
  @override
  $ProviderElement<NoteActionRunner> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NoteActionRunner create(Ref ref) {
    return noteActionRunner(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NoteActionRunner value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NoteActionRunner>(value),
    );
  }
}

String _$noteActionRunnerHash() => r'35847f6d43966de3ab967e58fab5218391609280';

/// Where Android hands this engine notification actions (`tix/note-actions`).

@ProviderFor(noteActionBridge)
final noteActionBridgeProvider = NoteActionBridgeProvider._();

/// Where Android hands this engine notification actions (`tix/note-actions`).

final class NoteActionBridgeProvider
    extends
        $FunctionalProvider<
          NoteActionBridge,
          NoteActionBridge,
          NoteActionBridge
        >
    with $Provider<NoteActionBridge> {
  /// Where Android hands this engine notification actions (`tix/note-actions`).
  NoteActionBridgeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteActionBridgeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteActionBridgeHash();

  @$internal
  @override
  $ProviderElement<NoteActionBridge> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NoteActionBridge create(Ref ref) {
    return noteActionBridge(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NoteActionBridge value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NoteActionBridge>(value),
    );
  }
}

String _$noteActionBridgeHash() => r'd796bd9b9c1cd8414bad63472447dbdfdec11845';
