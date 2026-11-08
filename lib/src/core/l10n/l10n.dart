// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:tix_mobile/l10n/generated/app_localizations.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';

export 'package:tix_mobile/l10n/generated/app_localizations.dart';

/// Short access to the app's strings.
extension L10nContext on BuildContext {
  /// The strings for this context's locale.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// What to tell a person about [error].
String errorMessage(AppLocalizations l10n, Object error) {
  if (error is! TixException) return l10n.errorUnknown;
  final message = error.message;
  return switch (error.kind) {
    TixErrorKind.invalid =>
      message.isEmpty ? l10n.errorUnknown : l10n.errorInvalid(message),
    TixErrorKind.unauthenticated => l10n.errorUnauthenticated,
    TixErrorKind.forbidden => l10n.errorForbidden,
    TixErrorKind.notFound || TixErrorKind.noTaskAvailable =>
      message.isEmpty ? l10n.errorNotFound : '${l10n.errorNotFound} $message',
    TixErrorKind.conflict || TixErrorKind.leaseExpired => l10n.errorConflict,
    TixErrorKind.preconditionFailed =>
      message.isEmpty ? l10n.errorUnknown : l10n.errorPrecondition(message),
    TixErrorKind.upstream || TixErrorKind.internal =>
      error.requestId == null
          ? l10n.errorServer
          : '${l10n.errorServer} ${l10n.errorRequestId(error.requestId!)}',
    TixErrorKind.network => l10n.errorNetwork,
    TixErrorKind.timeout => l10n.errorTimeout,
    TixErrorKind.notTix => l10n.errorNotTix,
    TixErrorKind.badUrl => l10n.errorBadUrl,
    TixErrorKind.tokenRequired => l10n.errorTokenRequired,
    TixErrorKind.badCredentials => l10n.errorBadCredentials,
    TixErrorKind.emailRequired => l10n.errorEmailRequired,
    TixErrorKind.passwordRequired => l10n.errorPasswordRequired,
    TixErrorKind.codeRequired => l10n.errorCodeRequired,
    TixErrorKind.secondFactorSetup => l10n.errorSecondFactorSetup,
    TixErrorKind.passwordChange => l10n.errorPasswordChange,
    TixErrorKind.tenantRequired => l10n.errorTenantRequired,
    TixErrorKind.engineUnavailable => l10n.errorEngineUnavailable,
    TixErrorKind.unknown =>
      message.isEmpty ? l10n.errorUnknown : '${l10n.errorUnknown} $message',
  };
}
