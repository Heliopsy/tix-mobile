// SPDX-License-Identifier: AGPL-3.0-or-later

/// A tenant's icon, and what changing it sends.
library;

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show ProjectIconFile;

export 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show ProjectIconFile;

/// The icon a tenant wears: at most one of [text], [name] and [image].
///
/// Read by hand until `tix.lock` pins the tix release with tenant icons;
/// then it is built from the generated `Tenant`, `Actor` and
/// `AccountMembership`.
@immutable
class TenantIcon {
  /// An icon of [text], built-in [name] or uploaded [image]; none by default.
  const TenantIcon({this.text = '', this.name = '', this.image = ''});

  /// The icon fields of a tenant as `GET /tenants/{ref}` reports them, and
  /// of a membership in `whoami`.
  factory TenantIcon.fromJson(Map<String, dynamic> json) => TenantIcon(
    text: json['icon'] as String? ?? '',
    name: json['icon_name'] as String? ?? '',
    image: json['icon_image'] as String? ?? '',
  );

  /// The icon of the caller's own tenant as `whoami` reports it.
  factory TenantIcon.ofActor(Map<String, dynamic> json) => TenantIcon(
    text: json['tenant_icon'] as String? ?? '',
    name: json['tenant_icon_name'] as String? ?? '',
    image: json['tenant_icon_image'] as String? ?? '',
  );

  /// One emoji or a one or two letter monogram.
  final String text;

  /// One of tix's built-in icons.
  final String name;

  /// The digest of an uploaded image, read from `GET /tenants/{ref}/icon`.
  final String image;

  /// Whether the tenant has no icon, and wears the monogram of its name.
  bool get isEmpty => text.isEmpty && name.isEmpty && image.isEmpty;

  /// As [TenantIcon.fromJson] reads it.
  Map<String, dynamic> toJson() => {
    if (text.isNotEmpty) 'icon': text,
    if (name.isNotEmpty) 'icon_name': name,
    if (image.isNotEmpty) 'icon_image': image,
  };

  @override
  bool operator ==(Object other) =>
      other is TenantIcon &&
      other.text == text &&
      other.name == name &&
      other.image == image;

  @override
  int get hashCode => Object.hash(text, name, image);
}

/// A new icon for a tenant: exactly one field is set, as the icon fields of
/// `PATCH /tenants/{ref}` take it. An empty [icon] clears the icon.
@immutable
class TenantIconChange {
  /// Sets an emoji or monogram; empty clears the icon.
  const TenantIconChange.text(String this.icon) : iconName = null, file = null;

  /// Sets the built-in icon [name].
  const TenantIconChange.builtin(String name)
    : icon = null,
      iconName = name,
      file = null;

  /// Uploads [file] as the icon.
  const TenantIconChange.image(ProjectIconFile this.file)
    : icon = null,
      iconName = null;

  /// The text icon, or empty for none.
  final String? icon;

  /// The built-in icon.
  final String? iconName;

  /// The uploaded image.
  final ProjectIconFile? file;

  /// The request body.
  Map<String, dynamic> toJson() => {
    if (icon != null) 'icon': icon,
    if (iconName != null) 'icon_name': iconName,
    if (file != null) 'icon_file': file!.toJson(),
  };
}
