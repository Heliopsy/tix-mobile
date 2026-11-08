// SPDX-License-Identifier: AGPL-3.0-or-later

@DefaultAsset('package:tix_mobile/libtix')
library;

import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/local/local_engine.dart';

// The C ABI of tix's embedded/libtix (tix docs/embedding.md). The library is
// the code asset hook/build.dart bundles; Flutter resolves it per platform.

@Native<Pointer<Utf8> Function(Pointer<Utf8>)>(symbol: 'TixStart')
external Pointer<Utf8> _start(Pointer<Utf8> options);

@Native<Pointer<Utf8> Function(Int64)>(symbol: 'TixStop')
external Pointer<Utf8> _stop(int handle);

@Native<Pointer<Utf8> Function(Int64)>(symbol: 'TixTenants')
external Pointer<Utf8> _tenants(int handle);

@Native<Pointer<Utf8> Function(Int64, Pointer<Utf8>)>(symbol: 'TixCreateTenant')
external Pointer<Utf8> _createTenant(int handle, Pointer<Utf8> request);

@Native<Pointer<Utf8> Function(Int64, Pointer<Utf8>)>(symbol: 'TixToken')
external Pointer<Utf8> _token(int handle, Pointer<Utf8> request);

@Native<Pointer<Utf8> Function()>(symbol: 'TixVersion')
external Pointer<Utf8> _version();

@Native<Void Function(Pointer<Utf8>)>(symbol: 'TixFree')
external void _free(Pointer<Utf8> p);

/// Decodes the JSON answer [p], frees it, and throws its error if it is one.
Map<String, Object?> _answer(Pointer<Utf8> p) {
  final String text;
  try {
    text = p.toDartString();
  } finally {
    _free(p);
  }
  final decoded = jsonDecode(text);
  if (decoded is! Map<String, Object?>) {
    throw TixException(TixErrorKind.internal, message: text);
  }
  final error = decoded['error'];
  if (error is Map<String, Object?>) throw TixException.fromEngine(error);
  return decoded;
}

/// Calls [f] with [request] as a C string, freed afterwards.
Map<String, Object?> _withRequest(
  Map<String, Object?> request,
  Pointer<Utf8> Function(Pointer<Utf8>) f,
) {
  final arg = jsonEncode(request).toNativeUtf8();
  try {
    return _answer(f(arg));
  } finally {
    malloc.free(arg);
  }
}

int _handle(LocalHandle h) => int.parse(h.id);

/// [LocalTixEngine] over the bundled libtix. Every call blocks in tix, so
/// each runs on a short-lived isolate, off the UI isolate.
class FfiLocalTixEngine implements LocalTixEngine {
  const FfiLocalTixEngine._();

  /// The engine when this build bundles libtix and it loads; null otherwise.
  static FfiLocalTixEngine? load() {
    try {
      _answer(_version());
      return const FfiLocalTixEngine._();
      // An unresolvable @Native function throws ArgumentError on first call:
      // that is how a build without the code asset shows itself.
      // ignore: avoid_catching_errors
    } on ArgumentError {
      return null;
    }
  }

  @override
  Future<LocalHandle> start({
    required String dbPath,
    bool initIfMissing = true,
    String? listen,
  }) async {
    final out = await Isolate.run(
      () => _withRequest({
        'db_path': dbPath,
        'init_if_missing': initIfMissing,
        'listen': ?listen,
      }, _start),
    );
    return LocalHandle(id: '${out['handle']}', baseUrl: '${out['url']}');
  }

  @override
  Future<void> stop(LocalHandle h) async {
    final handle = _handle(h);
    await Isolate.run(() => _answer(_stop(handle)));
  }

  @override
  Future<List<TenantRef>> tenants(LocalHandle h) async {
    final handle = _handle(h);
    final out = await Isolate.run(() => _answer(_tenants(handle)));
    final list = out['tenants'];
    return [
      if (list is List)
        for (final t in list.whereType<Map<String, Object?>>()) _tenant(t),
    ];
  }

  @override
  Future<TenantRef> createTenant(
    LocalHandle h, {
    required String key,
    required String name,
  }) async {
    final handle = _handle(h);
    final out = await Isolate.run(
      () => _withRequest({
        'key': key,
        'name': name,
      }, (p) => _createTenant(handle, p)),
    );
    return _tenant(out);
  }

  @override
  Future<String> token(
    LocalHandle h, {
    required String tenant,
    required String name,
    List<String>? scopes,
  }) async {
    final handle = _handle(h);
    final out = await Isolate.run(
      () => _withRequest({
        'tenant': tenant,
        'name': name,
        'scopes': ?scopes,
        'ttl': 'never',
      }, (p) => _token(handle, p)),
    );
    return '${out['token']}';
  }

  @override
  Future<String> version() async {
    final out = await Isolate.run(() => _answer(_version()));
    return '${out['version']}';
  }

  static TenantRef _tenant(Map<String, Object?> t) {
    final key = '${t['key'] ?? ''}';
    final name = '${t['name'] ?? ''}';
    return TenantRef(key: key, name: name.isEmpty ? key : name);
  }
}
