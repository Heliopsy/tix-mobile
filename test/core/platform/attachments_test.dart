// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart';

void main() {
  test('media types come from the extension, in any case', () {
    expect(mimeTypeOf('notes.TXT'), 'text/plain');
    expect(mimeTypeOf('run.log'), 'text/plain');
    expect(mimeTypeOf('a.json'), 'application/json');
    expect(mimeTypeOf('a.csv'), 'text/csv');
    expect(mimeTypeOf('a.pdf'), 'application/pdf');
    expect(mimeTypeOf('photo.JPEG'), 'image/jpeg');
    expect(mimeTypeOf('a.png'), 'image/png');
    expect(mimeTypeOf('a.zip'), 'application/zip');
  });

  test('anything else is an octet stream', () {
    expect(mimeTypeOf('Makefile'), 'application/octet-stream');
    expect(mimeTypeOf('a.weird'), 'application/octet-stream');
  });
}
