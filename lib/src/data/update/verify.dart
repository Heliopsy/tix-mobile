// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' show sha256;
import 'package:cryptography/cryptography.dart';

/// Reads `sha256sum` output into file name to lowercase hex digest. Lines
/// that are not a digest and a name are skipped; binary mode's `*` before
/// the name is dropped.
Map<String, String> parseSha256Sums(String text) {
  final sums = <String, String>{};
  final line = RegExp(r'^([0-9a-fA-F]{64}) [ *](.+)$');
  for (final l in const LineSplitter().convert(text)) {
    final m = line.firstMatch(l.trimRight());
    if (m != null) sums[m[2]!] = m[1]!.toLowerCase();
  }
  return sums;
}

/// The SHA-256 of [file] as lowercase hex, read as a stream.
Future<String> sha256OfFile(File file) async =>
    (await sha256.bind(file.openRead()).first).toString();

/// Whether [signature] is a valid Ed25519 signature of [message] by
/// [publicKey], the base64 of the key's 32 raw bytes. False for an empty or
/// malformed key or signature.
Future<bool> verifyEd25519({
  required List<int> message,
  required List<int> signature,
  required String publicKey,
}) async {
  final List<int> key;
  try {
    key = base64.decode(publicKey.trim());
  } on FormatException {
    return false;
  }
  if (key.length != 32 || signature.length != 64) return false;
  return await Ed25519().verify(
    message,
    signature: Signature(
      signature,
      publicKey: SimplePublicKey(key, type: KeyPairType.ed25519),
    ),
  );
}
