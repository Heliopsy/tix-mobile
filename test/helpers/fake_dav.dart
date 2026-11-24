// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:ui' show Rect;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:tix_mobile/src/core/platform/dav_handoff.dart';

import 'fake_tix.dart';

/// tix's CalDAV setup routes for [FakeTix], as heliopsy/tix#380 answers
/// them; `FakeDav.on` installs them.
class FakeDav {
  /// Serves on [server].
  FakeDav.on(this.server) {
    server.routes.add(_route);
  }

  /// The server this answers for.
  final FakeTix server;

  /// What `dav.info` answers.
  Map<String, Object?> info = {
    'enabled': true,
    'path': '/dav/',
    'url': 'https://tix.example/dav/',
    'username': 'ana@example.com',
    'write': false,
    'collections': ['assigned', 'projects', 'all'],
  };

  /// The caller's app passwords, metadata only.
  final passwords = <Map<String, Object?>>[
    {
      'id': 'p1',
      'name': 'iPhone',
      'actor_id': 'me',
      'collections': 'assigned',
      'read_only': false,
      'scopes': ['caldav'],
      'created_at': '2026-10-20T00:00:00Z',
      'last_used_at': '2026-10-31T08:00:00Z',
    },
  ];

  /// Every app password this server issued.
  final issued = <String>[];

  /// The bodies `dav.password.create` was sent.
  final created = <Map<String, dynamic>>[];

  /// The ids `dav.password.revoke` was sent.
  final revoked = <String>[];

  var _n = 0;

  FakeResponse? _route(RequestOptions o, String path, FakeCaller caller) {
    final body = o.data is Map<String, dynamic>
        ? o.data as Map<String, dynamic>
        : const <String, dynamic>{};
    switch ((o.method, path)) {
      case ('GET', '/api/v1/dav'):
        return FakeResponse(200, info);
      case ('GET', '/api/v1/dav/passwords'):
        return FakeResponse(200, {'items': passwords, 'next_cursor': ''});
      case ('POST', '/api/v1/dav/passwords'):
        created.add(body);
        final name = body['name'] as String? ?? '';
        if (name.isEmpty) {
          return FakeResponse(400, envelope('invalid', 'name is required'));
        }
        if (passwords.any(
          (p) => p['name'] == name && p['revoked_at'] == null,
        )) {
          return FakeResponse(
            409,
            envelope('conflict', 'an app password named "$name" exists'),
          );
        }
        final secret = 'tix_pat_dav-secret-${++_n}-Zq7';
        issued.add(secret);
        final p = <String, Object?>{
          'id': 'p${100 + _n}',
          'name': name,
          'actor_id': 'me',
          'collections': body['collections'] ?? 'assigned',
          'read_only': body['read_only'] ?? false,
          'scopes': ['caldav'],
          'created_at': '2026-11-01T12:00:00Z',
          'expires_at': body['expires_at'],
        };
        passwords.add(p);
        return FakeResponse(201, {
          ...p,
          'password': secret,
          'username': info['username'],
          'url': info['url'],
          'path': '/dav/',
        });
      case ('DELETE', final String p)
          when p.startsWith('/api/v1/dav/passwords/'):
        final id = p.substring('/api/v1/dav/passwords/'.length);
        revoked.add(id);
        for (final row in passwords) {
          if (row['id'] == id) row['revoked_at'] ??= '2026-11-01T12:00:00Z';
        }
        return const FakeResponse(204);
    }
    return null;
  }
}

/// A hand-off that records what it was asked and answers from fields.
class FakeDavHandoff implements DavHandoff {
  FakeDavHandoff({
    this.platform = DavPlatform.linux,
    this.installed = true,
    this.opens = true,
    this.serves = true,
    this.play = false,
  });

  @override
  final DavPlatform platform;

  /// Whether DAVx5 is installed.
  bool installed;

  /// Whether DAVx5, Safari or System Settings open.
  bool opens;

  /// Whether Safari fetches the profile.
  bool serves;

  /// Whether this is the Google Play build.
  bool play;

  /// The accounts handed to DAVx5.
  final davx5 = <DavAccount>[];

  /// The profiles opened and saved.
  final profiles = <String>[];
  final saved = <String>[];

  /// The secrets copied.
  final copied = <String>[];

  /// How many times the sheet cleaned up.
  int cleanUps = 0;

  @override
  DavStoreLinks get storeLinks => davStoreLinks(play: play);

  @override
  Future<bool> davx5Installed() async => installed;

  @override
  Future<bool> openDavx5(DavAccount account) async {
    davx5.add(account);
    return opens;
  }

  @override
  Future<ProfileOpening> openProfile(String profile) async {
    profiles.add(profile);
    return ProfileOpening(opened: opens, served: Future.value(serves));
  }

  @override
  Future<bool> saveProfile(String profile, {Rect? origin}) async {
    saved.add(profile);
    return true;
  }

  @override
  Future<ClipMark> copySecret(String value) async {
    copied.add(value);
    return switch (platform) {
      DavPlatform.ios => ClipMark.expires,
      DavPlatform.android => ClipMark.hidden,
      _ => ClipMark.plain,
    };
  }

  @override
  Future<void> cleanUp() async => cleanUps++;

  /// The override that puts this fake in place.
  Override get asOverride => davHandoffProvider.overrideWithValue(this);
}
