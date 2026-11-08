// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'account.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The caller's account history, newest first, a page at a time.

@ProviderFor(AccountLog)
final accountLogProvider = AccountLogProvider._();

/// The caller's account history, newest first, a page at a time.
final class AccountLogProvider
    extends $AsyncNotifierProvider<AccountLog, Paged<AccountLogEntry>> {
  /// The caller's account history, newest first, a page at a time.
  AccountLogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountLogProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountLogHash();

  @$internal
  @override
  AccountLog create() => AccountLog();
}

String _$accountLogHash() => r'3412ebc8db3217daf19c9aae201e84513ac2fec0';

/// The caller's account history, newest first, a page at a time.

abstract class _$AccountLog extends $AsyncNotifier<Paged<AccountLogEntry>> {
  FutureOr<Paged<AccountLogEntry>> build();
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
    return element.handleCreate(ref, build);
  }
}

/// The caller's calendar feed, null when there is none.
///
/// The feed's address is never held here: create and rotate return it to
/// the screen that shows it once.

@ProviderFor(Calendar)
final calendarProvider = CalendarProvider._();

/// The caller's calendar feed, null when there is none.
///
/// The feed's address is never held here: create and rotate return it to
/// the screen that shows it once.
final class CalendarProvider
    extends $AsyncNotifierProvider<Calendar, CalendarFeed?> {
  /// The caller's calendar feed, null when there is none.
  ///
  /// The feed's address is never held here: create and rotate return it to
  /// the screen that shows it once.
  CalendarProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarHash();

  @$internal
  @override
  Calendar create() => Calendar();
}

String _$calendarHash() => r'b943bb2f31841fb3dabea56b25402048786e2c16';

/// The caller's calendar feed, null when there is none.
///
/// The feed's address is never held here: create and rotate return it to
/// the screen that shows it once.

abstract class _$Calendar extends $AsyncNotifier<CalendarFeed?> {
  FutureOr<CalendarFeed?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CalendarFeed?>, CalendarFeed?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CalendarFeed?>, CalendarFeed?>,
              AsyncValue<CalendarFeed?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
