// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'files.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The platform's file dialogs.

@ProviderFor(filePicking)
final filePickingProvider = FilePickingProvider._();

/// The platform's file dialogs.

final class FilePickingProvider
    extends $FunctionalProvider<FilePicking, FilePicking, FilePicking>
    with $Provider<FilePicking> {
  /// The platform's file dialogs.
  FilePickingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filePickingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filePickingHash();

  @$internal
  @override
  $ProviderElement<FilePicking> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FilePicking create(Ref ref) {
    return filePicking(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FilePicking value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FilePicking>(value),
    );
  }
}

String _$filePickingHash() => r'5e7794e58782e48c0e75af614803578f76e1a421';
