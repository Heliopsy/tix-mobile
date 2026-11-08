// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/core/config/server_url.dart';

export 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show AcceptInviteInput, InvitePreview;

/// The secret prefix tix gives every invite token.
const inviteTokenPrefix = 'tix_inv_';

/// An invite link, `https://<server>/invite/<token>`, read into the server
/// it came from and the token it carries.
@immutable
class InviteLink {
  /// The invite [token] issued by the server at [baseUrl].
  const InviteLink({required this.baseUrl, required this.token});

  /// Reads [input], a pasted or shared link, or null when it is not one.
  /// A server under a path keeps it: `https://h/tix/invite/t` is `https://h/tix`.
  static InviteLink? parse(String input) {
    final match = RegExp(
      'https?://\\S*?/invite/($inviteTokenPrefix[A-Za-z0-9_-]+)',
    ).firstMatch(input);
    if (match == null) return null;
    final uri = Uri.tryParse(match[0]!);
    if (uri == null) return null;
    final root = uri.path.substring(0, uri.path.lastIndexOf('/invite/'));
    final baseUrl = normalizeServerUrl(
      Uri(
        scheme: uri.scheme,
        host: uri.host,
        port: uri.hasPort ? uri.port : null,
        path: root,
      ).toString(),
    );
    if (baseUrl == null) return null;
    return InviteLink(baseUrl: baseUrl, token: match[1]!);
  }

  /// The server root.
  final String baseUrl;

  /// The invite secret, starting [inviteTokenPrefix].
  final String token;

  @override
  bool operator ==(Object other) =>
      other is InviteLink && other.baseUrl == baseUrl && other.token == token;

  @override
  int get hashCode => Object.hash(baseUrl, token);
}
