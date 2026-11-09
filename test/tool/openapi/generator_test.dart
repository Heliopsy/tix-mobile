// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/openapi/generator.dart';

String _spec({String nested = ''}) =>
    '''
openapi: 3.1.0
paths:
  /things/{ref}:
    patch:
      operationId: thing.update
      parameters:
        - {in: path, name: ref, required: true, schema: {type: string}}
        - {in: header, name: Idempotency-Key, schema: {type: string}}
      requestBody:
        required: true
        content:
          application/json:
            schema: {\$ref: '#/components/schemas/UpdateThing'}
      responses:
        '204': {description: done}
  /notes:
    post:
      operationId: note.add
      requestBody:
        content:
          application/json:
            schema: {\$ref: '#/components/schemas/Note'}
      responses:
        '204': {description: done}
components:
  schemas:
    Level:
      type: string
      enum: [low, high]
    Note:
      type: object
      properties:
        text: {type: [string, "null"]}
        fields:
          type: object
          additionalProperties: {}
          description: Fields merges by key; a null value clears that field.
$nested
    UpdateThing:
      type: object
      properties:
        due_at:
          type: [string, "null"]
          format: date-time
          description: DueAt sets the due time; Null clears
            it and omitted leaves it.
        level:
          \$ref: '#/components/schemas/Level'
          description: Level; null removes it.
        name:
          type: [string, "null"]
          description: Name; null unsets it.
        title:
          type: [string, "null"]
          description: Title; omitted leaves it.
''';

void main() {
  final files = generate(_spec());
  final models = files['models.gen.dart']!;
  final client = files['client.gen.dart']!;

  test('a field whose description says null clears it is a Patch', () {
    expect(
      models,
      contains(
        "@JsonKey(name: 'due_at', includeFromJson: false, "
        'includeToJson: false) Patch<DateTime>? dueAt,',
      ),
    );
    expect(models, contains('Patch<Level>? level,'));
    expect(models, contains('Patch<String>? name,'));
    expect(models, contains("@JsonKey(name: 'title') String? title,"));
    expect(models, isNot(contains('Patch<Map')));
  });

  test('toBody adds every set Patch back, encoded by type', () {
    expect(models, contains('extension UpdateThingBody on UpdateThing {'));
    expect(
      models,
      contains(
        "if (dueAt case final p?) 'due_at': "
        'p.encode(const TixDateTime().toJson),',
      ),
    );
    expect(
      models,
      contains("if (level case final p?) 'level': p.encode((v) => v.value),"),
    );
    expect(models, contains("if (name case final p?) 'name': p.value,"));
    expect(models, isNot(contains('extension NoteBody')));
  });

  test('a header parameter is a named argument sent as that header', () {
    expect(client, contains('String? idempotencyKey,'));
    expect(client, contains("headers: {'Idempotency-Key': idempotencyKey}"));
  });

  test('the client sends toBody only for a class with a Patch', () {
    expect(client, contains('body: body.toBody()'));
    expect(client, contains('body: body?.toJson()'));
  });

  test('a clearable class nested in another schema is refused', () {
    const wrapper = r'''
    Wrapper:
      type: object
      properties:
        thing: {$ref: '#/components/schemas/UpdateThing'}''';
    final spec = _spec(nested: wrapper).replaceFirst(
      "#/components/schemas/Note'}",
      "#/components/schemas/Wrapper'}",
    );
    expect(
      () => generate(spec),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('UpdateThing'),
        ),
      ),
    );
  });
}
