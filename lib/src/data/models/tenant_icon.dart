// SPDX-License-Identifier: AGPL-3.0-or-later

/// A tenant's icon as the app keeps it beside a connection.
library;

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show AccountMembership, Actor, Tenant;

/// The icon a tenant wears: at most one of [text], [name] and [image].
@immutable
class TenantIcon {
  /// An icon of [text], built-in [name] or uploaded [image]; none by default.
  const TenantIcon({this.text = '', this.name = '', this.image = ''});

  /// The icon as it was stored with a connection.
  factory TenantIcon.fromJson(Map<String, dynamic> json) => TenantIcon(
    text: json['icon'] as String? ?? '',
    name: json['icon_name'] as String? ?? '',
    image: json['icon_image'] as String? ?? '',
  );

  /// The icon of tenant [t].
  factory TenantIcon.ofTenant(Tenant t) =>
      TenantIcon(text: t.icon, name: t.iconName, image: t.iconImage);

  /// The icon of the tenant [me] is in, as `whoami` reports it.
  factory TenantIcon.ofActor(Actor me) => TenantIcon(
    text: me.tenantIcon,
    name: me.tenantIconName,
    image: me.tenantIconImage,
  );

  /// The icon of the tenant of membership [m].
  factory TenantIcon.ofMembership(AccountMembership m) =>
      TenantIcon(text: m.icon, name: m.iconName, image: m.iconImage);

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
