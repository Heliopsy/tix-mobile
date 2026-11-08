// SPDX-License-Identifier: AGPL-3.0-or-later

/// Turns what someone typed into a server root URL, or null if it is not one.
///
/// Adds `https://` when no scheme is given, and drops trailing slashes and a
/// trailing `/api/v1` so either spelling of the address works.
String? normalizeServerUrl(String input) {
  var text = input.trim();
  if (text.isEmpty) return null;
  if (!text.contains('://')) text = 'https://$text';
  final uri = Uri.tryParse(text);
  if (uri == null ||
      !(uri.scheme == 'http' || uri.scheme == 'https') ||
      uri.host.isEmpty) {
    return null;
  }
  var path = uri.path.replaceAll(RegExp(r'/+$'), '');
  if (path.endsWith('/api/v1')) {
    path = path.substring(0, path.length - '/api/v1'.length);
  }
  return Uri(
    scheme: uri.scheme,
    userInfo: uri.userInfo,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: path,
  ).toString();
}
