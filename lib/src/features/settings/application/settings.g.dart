// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Theme and language choices.

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

/// Theme and language choices.

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  /// Theme and language choices.
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'12347d101927727d58d1e4a7c7d28b1cb4e83be0';

/// The chosen theme.

@ProviderFor(ThemeSetting)
final themeSettingProvider = ThemeSettingProvider._();

/// The chosen theme.
final class ThemeSettingProvider
    extends $NotifierProvider<ThemeSetting, ThemeChoice> {
  /// The chosen theme.
  ThemeSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeSettingHash();

  @$internal
  @override
  ThemeSetting create() => ThemeSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeChoice value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeChoice>(value),
    );
  }
}

String _$themeSettingHash() => r'1b44393a5071fc4125b3f3d5f846648b0f2ea91f';

/// The chosen theme.

abstract class _$ThemeSetting extends $Notifier<ThemeChoice> {
  ThemeChoice build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ThemeChoice, ThemeChoice>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeChoice, ThemeChoice>,
              ThemeChoice,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Whether the system theme goes pure black when the platform is dark.

@ProviderFor(SystemBlackSetting)
final systemBlackSettingProvider = SystemBlackSettingProvider._();

/// Whether the system theme goes pure black when the platform is dark.
final class SystemBlackSettingProvider
    extends $NotifierProvider<SystemBlackSetting, bool> {
  /// Whether the system theme goes pure black when the platform is dark.
  SystemBlackSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'systemBlackSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$systemBlackSettingHash();

  @$internal
  @override
  SystemBlackSetting create() => SystemBlackSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$systemBlackSettingHash() =>
    r'6c72cd380dc1e7fca245e1937a222a743f5300ea';

/// Whether the system theme goes pure black when the platform is dark.

abstract class _$SystemBlackSetting extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Whether the dark theme is drawn on pure black.

@ProviderFor(darkIsBlack)
final darkIsBlackProvider = DarkIsBlackProvider._();

/// Whether the dark theme is drawn on pure black.

final class DarkIsBlackProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the dark theme is drawn on pure black.
  DarkIsBlackProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'darkIsBlackProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$darkIsBlackHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return darkIsBlack(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$darkIsBlackHash() => r'f494cdb87e8c8b5634e0c38e725f62aa11e53cef';

/// The chosen language, null to follow the system.

@ProviderFor(LocaleSetting)
final localeSettingProvider = LocaleSettingProvider._();

/// The chosen language, null to follow the system.
final class LocaleSettingProvider
    extends $NotifierProvider<LocaleSetting, Locale?> {
  /// The chosen language, null to follow the system.
  LocaleSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeSettingHash();

  @$internal
  @override
  LocaleSetting create() => LocaleSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale?>(value),
    );
  }
}

String _$localeSettingHash() => r'6ae7248e6311223b285f08d855a705be774827f8';

/// The chosen language, null to follow the system.

abstract class _$LocaleSetting extends $Notifier<Locale?> {
  Locale? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Locale?, Locale?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Locale?, Locale?>,
              Locale?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
