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

String _$themeSettingHash() => r'f334ffab8d93ffe33f8e20655c7b4716417f7a4e';

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
    r'5ef2f05e0c3faeca8fb5cd6e427f3703db0aa663';

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

String _$localeSettingHash() => r'e3c6fab350efdff7d74f5c05c276013de2c3f387';

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

/// Whether widgets on the lock screen show counts only.

@ProviderFor(WidgetLockCountsSetting)
final widgetLockCountsSettingProvider = WidgetLockCountsSettingProvider._();

/// Whether widgets on the lock screen show counts only.
final class WidgetLockCountsSettingProvider
    extends $NotifierProvider<WidgetLockCountsSetting, bool> {
  /// Whether widgets on the lock screen show counts only.
  WidgetLockCountsSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'widgetLockCountsSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$widgetLockCountsSettingHash();

  @$internal
  @override
  WidgetLockCountsSetting create() => WidgetLockCountsSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$widgetLockCountsSettingHash() =>
    r'6a2975127aa0aab0d2c26cf3c94f6cf0cebf1077';

/// Whether widgets on the lock screen show counts only.

abstract class _$WidgetLockCountsSetting extends $Notifier<bool> {
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

/// Whether touch feedback is on, on this device.

@ProviderFor(HapticsSetting)
final hapticsSettingProvider = HapticsSettingProvider._();

/// Whether touch feedback is on, on this device.
final class HapticsSettingProvider
    extends $NotifierProvider<HapticsSetting, bool> {
  /// Whether touch feedback is on, on this device.
  HapticsSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hapticsSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hapticsSettingHash();

  @$internal
  @override
  HapticsSetting create() => HapticsSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hapticsSettingHash() => r'8e1ddedad1bc9df8e746e37ad8bf02e3d5aa8d9b';

/// Whether touch feedback is on, on this device.

abstract class _$HapticsSetting extends $Notifier<bool> {
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

/// Whether the app keeps still whatever the platform asks, on this device.

@ProviderFor(ReduceMotionSetting)
final reduceMotionSettingProvider = ReduceMotionSettingProvider._();

/// Whether the app keeps still whatever the platform asks, on this device.
final class ReduceMotionSettingProvider
    extends $NotifierProvider<ReduceMotionSetting, bool> {
  /// Whether the app keeps still whatever the platform asks, on this device.
  ReduceMotionSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reduceMotionSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reduceMotionSettingHash();

  @$internal
  @override
  ReduceMotionSetting create() => ReduceMotionSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$reduceMotionSettingHash() =>
    r'b59103a54bcb712085620f98584c26754ea0be49';

/// Whether the app keeps still whatever the platform asks, on this device.

abstract class _$ReduceMotionSetting extends $Notifier<bool> {
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

/// The screen the app opens on, on this device.

@ProviderFor(StartScreenSetting)
final startScreenSettingProvider = StartScreenSettingProvider._();

/// The screen the app opens on, on this device.
final class StartScreenSettingProvider
    extends $NotifierProvider<StartScreenSetting, StartScreen> {
  /// The screen the app opens on, on this device.
  StartScreenSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startScreenSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startScreenSettingHash();

  @$internal
  @override
  StartScreenSetting create() => StartScreenSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StartScreen value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StartScreen>(value),
    );
  }
}

String _$startScreenSettingHash() =>
    r'de1e00df883ba637dd36e59f4abd75ca1f3aafc1';

/// The screen the app opens on, on this device.

abstract class _$StartScreenSetting extends $Notifier<StartScreen> {
  StartScreen build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<StartScreen, StartScreen>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StartScreen, StartScreen>,
              StartScreen,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The reader's arrangements of the shared views, kept with their account.

@ProviderFor(ArrangementSettings)
final arrangementSettingsProvider = ArrangementSettingsProvider._();

/// The reader's arrangements of the shared views, kept with their account.
final class ArrangementSettingsProvider
    extends $NotifierProvider<ArrangementSettings, void> {
  /// The reader's arrangements of the shared views, kept with their account.
  ArrangementSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'arrangementSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$arrangementSettingsHash();

  @$internal
  @override
  ArrangementSettings create() => ArrangementSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$arrangementSettingsHash() =>
    r'66f6f33a623ef8cf2b2ad3ba4d2bc32348a0ec96';

/// The reader's arrangements of the shared views, kept with their account.

abstract class _$ArrangementSettings extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
