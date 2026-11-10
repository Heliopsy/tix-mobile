// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/update/verify.dart';

import '../../helpers/fake_update.dart';

void main() {
  group('parseSha256Sums', () {
    test('reads text and binary mode lines, skips the rest', () {
      final a = 'a' * 64;
      final b = 'B' * 64;
      final sums = parseSha256Sums(
        '$a  tix-mobile-0.12.0-linux-x64.tar.gz\n'
        '$b *tix-mobile-0.12.0-macos.zip\r\n'
        'garbage line\n'
        '${'c' * 63}  short.zip\n',
      );
      expect(sums, {
        'tix-mobile-0.12.0-linux-x64.tar.gz': a,
        'tix-mobile-0.12.0-macos.zip': 'b' * 64,
      });
    });
  });

  test('sha256OfFile hashes the whole file', () async {
    final dir = await Directory.systemTemp.createTemp('tix-verify-');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/abc');
    await file.writeAsString('abc');
    expect(
      await sha256OfFile(file),
      'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
    );
  });

  group('verifyEd25519', () {
    final message = utf8.encode('${'a' * 64}  tix.tar.gz\n');

    test('a signature by the pinned key holds', () async {
      final key = await testKey();
      expect(
        await verifyEd25519(
          message: message,
          signature: await sign(message, key),
          publicKey: key.public,
        ),
        isTrue,
      );
    });

    test('a changed message fails', () async {
      final key = await testKey();
      final signature = await sign(message, key);
      final changed = [...message]..[0] = 'b'.codeUnitAt(0);
      expect(
        await verifyEd25519(
          message: changed,
          signature: signature,
          publicKey: key.public,
        ),
        isFalse,
      );
    });

    test('another key fails', () async {
      final key = await testKey();
      final other = await testKey();
      expect(
        await verifyEd25519(
          message: message,
          signature: await sign(message, other),
          publicKey: key.public,
        ),
        isFalse,
      );
    });

    test('no key, a malformed key or a short signature fails', () async {
      final key = await testKey();
      final signature = await sign(message, key);
      for (final pinned in [
        '',
        'not base64!',
        base64.encode([1, 2, 3]),
      ]) {
        expect(
          await verifyEd25519(
            message: message,
            signature: signature,
            publicKey: pinned,
          ),
          isFalse,
          reason: pinned,
        );
      }
      expect(
        await verifyEd25519(
          message: message,
          signature: signature.sublist(0, 32),
          publicKey: key.public,
        ),
        isFalse,
      );
    });
  });
}
