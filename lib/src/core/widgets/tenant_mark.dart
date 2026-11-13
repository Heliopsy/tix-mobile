// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/session/tenant_icons.dart';
import 'package:tix_mobile/src/data/models/tenant_icon.dart';

/// The square a tenant wears, as a project does: its uploaded image, its
/// built-in icon, its emoji or monogram, else the monogram of its name, on
/// a hue drawn from its key so tenants stay apart at a glance.
class TenantMark extends ConsumerWidget {
  /// Draws tenant [name] wearing [icon], [size] square. The image is read
  /// for [tenantRef] with the active session only when [readImage].
  const TenantMark({
    required this.name,
    required this.icon,
    this.tenantRef = '',
    this.readImage = true,
    this.size = 32,
    super.key,
  });

  /// The tenant's name, for the monogram.
  final String name;

  /// Its icon.
  final TenantIcon icon;

  /// Its key or id, which the image is read by.
  final String tenantRef;

  /// Whether the active session may read the image; otherwise an image
  /// icon draws the monogram.
  final bool readImage;

  /// Width and height.
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = icon.image.isNotEmpty && readImage && tenantRef.isNotEmpty
        ? ref.watch(tenantIconImageProvider(tenantRef, icon.image)).value
        : null;
    return ProjectMark(
      name: name,
      colour: hueOf(tenantRef.isEmpty ? name : tenantRef).name,
      icon: icon.text,
      iconName: icon.name,
      size: size,
      image: image == null
          ? null
          : Image.memory(image, fit: BoxFit.cover, gaplessPlayback: true),
    );
  }
}
