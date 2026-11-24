// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:math';

/// What another app is set up with: the address, the user name and the app
/// password. Lives only as long as the setup sheet that holds it.
class DavAccount {
  /// An account at [url] for [username] signing in with [password].
  const DavAccount({
    required this.url,
    required this.username,
    required this.password,
  });

  /// The absolute CalDAV address, such as `https://tix.example.com/dav/`.
  final String url;

  /// The Basic user name tix gave.
  final String username;

  /// The app password.
  final String password;

  @override
  String toString() => 'DavAccount($url)';
}

/// The words a configuration profile shows, localised by the caller.
class DavProfileText {
  /// The account's name in Reminders, the profile's name in Settings and
  /// what it is for.
  const DavProfileText({
    required this.account,
    required this.displayName,
    required this.description,
  });

  /// The account's name in Reminders, such as `tix: Acme`.
  final String account;

  /// The profile's name in Settings.
  final String displayName;

  /// What the profile does, shown before installing.
  final String description;
}

/// The identifier of the profile for [connectionId]: the same on every
/// setup of one connection, so installing again replaces the account.
String davProfileIdentifier(String connectionId) {
  final id = connectionId.replaceAll(RegExp('[^A-Za-z0-9.-]'), '-');
  return 'red.tix.mobile.caldav.$id';
}

/// A random version 4 UUID from [random], upper case as Apple writes them.
String randomUuid(Random random) {
  final b = [for (var i = 0; i < 16; i++) random.nextInt(256)];
  b[6] = (b[6] & 0x0f) | 0x40;
  b[8] = (b[8] & 0x3f) | 0x80;
  final h = [for (final x in b) x.toRadixString(16).padLeft(2, '0')].join();
  return [
    h.substring(0, 8),
    h.substring(8, 12),
    h.substring(12, 16),
    h.substring(16, 20),
    h.substring(20),
  ].join('-').toUpperCase();
}

/// An Apple configuration profile with one `com.apple.caldav.account`
/// payload for [account], identified per [connectionId]. [payloadUuid] and
/// [profileUuid] are fresh for every profile.
String buildCalDavProfile({
  required DavAccount account,
  required String connectionId,
  required DavProfileText text,
  required String payloadUuid,
  required String profileUuid,
}) {
  final uri = Uri.parse(account.url);
  final ssl = uri.scheme == 'https';
  final port = uri.hasPort ? uri.port : (ssl ? 443 : 80);
  final id = davProfileIdentifier(connectionId);
  String s(String v) => '<string>${_xml(v)}</string>';
  return '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>PayloadContent</key>
  <array>
    <dict>
      <key>CalDAVAccountDescription</key>
      ${s(text.account)}
      <key>CalDAVHostName</key>
      ${s(uri.host)}
      <key>CalDAVPort</key>
      <integer>$port</integer>
      <key>CalDAVPrincipalURL</key>
      ${s(account.url)}
      <key>CalDAVUseSSL</key>
      ${ssl ? '<true/>' : '<false/>'}
      <key>CalDAVUsername</key>
      ${s(account.username)}
      <key>CalDAVPassword</key>
      ${s(account.password)}
      <key>PayloadDisplayName</key>
      ${s(text.account)}
      <key>PayloadIdentifier</key>
      ${s('$id.account')}
      <key>PayloadType</key>
      <string>com.apple.caldav.account</string>
      <key>PayloadUUID</key>
      ${s(payloadUuid)}
      <key>PayloadVersion</key>
      <integer>1</integer>
    </dict>
  </array>
  <key>PayloadDescription</key>
  ${s(text.description)}
  <key>PayloadDisplayName</key>
  ${s(text.displayName)}
  <key>PayloadIdentifier</key>
  ${s(id)}
  <key>PayloadRemovalDisallowed</key>
  <false/>
  <key>PayloadType</key>
  <string>Configuration</string>
  <key>PayloadUUID</key>
  ${s(profileUuid)}
  <key>PayloadVersion</key>
  <integer>1</integer>
</dict>
</plist>
''';
}

String _xml(String v) => v
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&apos;');

/// The address DAVx5's login opens with for [url]: `caldavs://` for https,
/// `caldav://` for http, the host, port and path kept, never any user info.
/// The user name and password travel as intent extras instead.
String davx5Address(String url) {
  final uri = Uri.parse(url);
  final scheme = uri.scheme == 'https' ? 'caldavs' : 'caldav';
  return Uri(
    scheme: scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: uri.path.isEmpty ? '/' : uri.path,
  ).toString();
}
