// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'global_admin.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every tenant of the installation, for a global admin; anybody else
/// sees their own.

@ProviderFor(TenantDirectory)
final tenantDirectoryProvider = TenantDirectoryProvider._();

/// Every tenant of the installation, for a global admin; anybody else
/// sees their own.
final class TenantDirectoryProvider
    extends $AsyncNotifierProvider<TenantDirectory, Paged<Tenant>> {
  /// Every tenant of the installation, for a global admin; anybody else
  /// sees their own.
  TenantDirectoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tenantDirectoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tenantDirectoryHash();

  @$internal
  @override
  TenantDirectory create() => TenantDirectory();
}

String _$tenantDirectoryHash() => r'5a72d60f6afa391fd48c94dab4072b5d519bff15';

/// Every tenant of the installation, for a global admin; anybody else
/// sees their own.

abstract class _$TenantDirectory extends $AsyncNotifier<Paged<Tenant>> {
  FutureOr<Paged<Tenant>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Paged<Tenant>>, Paged<Tenant>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Paged<Tenant>>, Paged<Tenant>>,
              AsyncValue<Paged<Tenant>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// How the active connection can open tenant [key].

@ProviderFor(tenantAccess)
final tenantAccessProvider = TenantAccessFamily._();

/// How the active connection can open tenant [key].

final class TenantAccessProvider
    extends $FunctionalProvider<TenantAccess, TenantAccess, TenantAccess>
    with $Provider<TenantAccess> {
  /// How the active connection can open tenant [key].
  TenantAccessProvider._({
    required TenantAccessFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tenantAccessProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tenantAccessHash();

  @override
  String toString() {
    return r'tenantAccessProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<TenantAccess> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TenantAccess create(Ref ref) {
    final argument = this.argument as String;
    return tenantAccess(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TenantAccess value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TenantAccess>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TenantAccessProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tenantAccessHash() => r'3511c675aff9f7c3b38a949d02dfef6d6edbc259';

/// How the active connection can open tenant [key].

final class TenantAccessFamily extends $Family
    with $FunctionalFamilyOverride<TenantAccess, String> {
  TenantAccessFamily._()
    : super(
        retry: null,
        name: r'tenantAccessProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// How the active connection can open tenant [key].

  TenantAccessProvider call(String key) =>
      TenantAccessProvider._(argument: key, from: this);

  @override
  String toString() => r'tenantAccessProvider';
}

/// The users of tenant [tenantRef] with their role there.

@ProviderFor(TenantUsers)
final tenantUsersProvider = TenantUsersFamily._();

/// The users of tenant [tenantRef] with their role there.
final class TenantUsersProvider
    extends $AsyncNotifierProvider<TenantUsers, Paged<TenantUser>> {
  /// The users of tenant [tenantRef] with their role there.
  TenantUsersProvider._({
    required TenantUsersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tenantUsersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tenantUsersHash();

  @override
  String toString() {
    return r'tenantUsersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TenantUsers create() => TenantUsers();

  @override
  bool operator ==(Object other) {
    return other is TenantUsersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tenantUsersHash() => r'b09212f6f7efe1e68d8a9a0b6ff85af1405092e7';

/// The users of tenant [tenantRef] with their role there.

final class TenantUsersFamily extends $Family
    with
        $ClassFamilyOverride<
          TenantUsers,
          AsyncValue<Paged<TenantUser>>,
          Paged<TenantUser>,
          FutureOr<Paged<TenantUser>>,
          String
        > {
  TenantUsersFamily._()
    : super(
        retry: null,
        name: r'tenantUsersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The users of tenant [tenantRef] with their role there.

  TenantUsersProvider call(String tenantRef) =>
      TenantUsersProvider._(argument: tenantRef, from: this);

  @override
  String toString() => r'tenantUsersProvider';
}

/// The users of tenant [tenantRef] with their role there.

abstract class _$TenantUsers extends $AsyncNotifier<Paged<TenantUser>> {
  late final _$args = ref.$arg as String;
  String get tenantRef => _$args;

  FutureOr<Paged<TenantUser>> build(String tenantRef);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<Paged<TenantUser>>, Paged<TenantUser>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Paged<TenantUser>>, Paged<TenantUser>>,
              AsyncValue<Paged<TenantUser>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// The hostnames mapped to tenant [tenantRef], each with whether it is
/// shared.

@ProviderFor(TenantDomains)
final tenantDomainsProvider = TenantDomainsFamily._();

/// The hostnames mapped to tenant [tenantRef], each with whether it is
/// shared.
final class TenantDomainsProvider
    extends $AsyncNotifierProvider<TenantDomains, List<Domain>> {
  /// The hostnames mapped to tenant [tenantRef], each with whether it is
  /// shared.
  TenantDomainsProvider._({
    required TenantDomainsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tenantDomainsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tenantDomainsHash();

  @override
  String toString() {
    return r'tenantDomainsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TenantDomains create() => TenantDomains();

  @override
  bool operator ==(Object other) {
    return other is TenantDomainsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tenantDomainsHash() => r'beda571d0bc53a06fa195694e9c61d5a5e27f0e0';

/// The hostnames mapped to tenant [tenantRef], each with whether it is
/// shared.

final class TenantDomainsFamily extends $Family
    with
        $ClassFamilyOverride<
          TenantDomains,
          AsyncValue<List<Domain>>,
          List<Domain>,
          FutureOr<List<Domain>>,
          String
        > {
  TenantDomainsFamily._()
    : super(
        retry: null,
        name: r'tenantDomainsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The hostnames mapped to tenant [tenantRef], each with whether it is
  /// shared.

  TenantDomainsProvider call(String tenantRef) =>
      TenantDomainsProvider._(argument: tenantRef, from: this);

  @override
  String toString() => r'tenantDomainsProvider';
}

/// The hostnames mapped to tenant [tenantRef], each with whether it is
/// shared.

abstract class _$TenantDomains extends $AsyncNotifier<List<Domain>> {
  late final _$args = ref.$arg as String;
  String get tenantRef => _$args;

  FutureOr<List<Domain>> build(String tenantRef);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Domain>>, List<Domain>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Domain>>, List<Domain>>,
              AsyncValue<List<Domain>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Every global admin of the installation.

@ProviderFor(GlobalAdmins)
final globalAdminsProvider = GlobalAdminsProvider._();

/// Every global admin of the installation.
final class GlobalAdminsProvider
    extends $AsyncNotifierProvider<GlobalAdmins, List<User>> {
  /// Every global admin of the installation.
  GlobalAdminsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'globalAdminsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$globalAdminsHash();

  @$internal
  @override
  GlobalAdmins create() => GlobalAdmins();
}

String _$globalAdminsHash() => r'ee761693f3ba878f7afc6a767c21f72560e985d1';

/// Every global admin of the installation.

abstract class _$GlobalAdmins extends $AsyncNotifier<List<User>> {
  FutureOr<List<User>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<User>>, List<User>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<User>>, List<User>>,
              AsyncValue<List<User>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The log of the account [email], newest first.

@ProviderFor(AccountLog)
final accountLogProvider = AccountLogFamily._();

/// The log of the account [email], newest first.
final class AccountLogProvider
    extends $AsyncNotifierProvider<AccountLog, Paged<AccountLogEntry>> {
  /// The log of the account [email], newest first.
  AccountLogProvider._({
    required AccountLogFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'accountLogProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountLogHash();

  @override
  String toString() {
    return r'accountLogProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AccountLog create() => AccountLog();

  @override
  bool operator ==(Object other) {
    return other is AccountLogProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountLogHash() => r'42d446a8b8b725530e46f28ca969d34d313e6917';

/// The log of the account [email], newest first.

final class AccountLogFamily extends $Family
    with
        $ClassFamilyOverride<
          AccountLog,
          AsyncValue<Paged<AccountLogEntry>>,
          Paged<AccountLogEntry>,
          FutureOr<Paged<AccountLogEntry>>,
          String
        > {
  AccountLogFamily._()
    : super(
        retry: null,
        name: r'accountLogProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The log of the account [email], newest first.

  AccountLogProvider call(String email) =>
      AccountLogProvider._(argument: email, from: this);

  @override
  String toString() => r'accountLogProvider';
}

/// The log of the account [email], newest first.

abstract class _$AccountLog extends $AsyncNotifier<Paged<AccountLogEntry>> {
  late final _$args = ref.$arg as String;
  String get email => _$args;

  FutureOr<Paged<AccountLogEntry>> build(String email);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<Paged<AccountLogEntry>>, Paged<AccountLogEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Paged<AccountLogEntry>>,
                Paged<AccountLogEntry>
              >,
              AsyncValue<Paged<AccountLogEntry>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
