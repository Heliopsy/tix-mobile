// SPDX-License-Identifier: AGPL-3.0-or-later

/// What a tix server offers by the version it reports, for operations the
/// vendored spec does not have yet and so cannot be bound in registry.dart.
library;

/// The first tix release with tenant icons (`tenant.icon` and the icon
/// fields of `tenant.update`). Set to the release that ships them when
/// `tix.lock` is bumped to it.
const tenantIconsSince = (0, 61, 0);

/// Whether a server reporting [version] has tenant icons. A version the
/// app cannot read, such as a development build, is taken to have them.
bool supportsTenantIcons(String version) {
  final parsed = _parse(version);
  if (parsed == null) return true;
  return _compare(parsed, tenantIconsSince) >= 0;
}

(int, int, int)? _parse(String version) {
  final m = RegExp(r'^v?(\d+)\.(\d+)\.(\d+)').firstMatch(version.trim());
  if (m == null) return null;
  return (int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
}

int _compare((int, int, int) a, (int, int, int) b) {
  if (a.$1 != b.$1) return a.$1.compareTo(b.$1);
  if (a.$2 != b.$2) return a.$2.compareTo(b.$2);
  return a.$3.compareTo(b.$3);
}
