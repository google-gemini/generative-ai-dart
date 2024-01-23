// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';
import 'dart:typed_data';

final class Content {
  final String? role;
  final List<Part> parts;
  Content(this.role, this.parts);

  static Content text(String text) => Content('user', [Text(text)]);
  static Content data(String mimeType, Uint8List bytes) =>
      Content('user', [Data(mimeType, bytes)]);
  static Content multi(Iterable<Part> parts) => Content('user', [...parts]);
  static Content model(Iterable<Part> parts) => Content('model', [...parts]);

  Map toJson() => {if (role case final role?) 'role': role, 'parts': parts};
}

Content parseContent(Object jsonObject) {
  return switch (jsonObject) {
    {'parts': final List<Object?> parts} => Content(
        switch (jsonObject) {
          {'role': String role} => role,
          _ => null,
        },
        parts.map(_parsePart).toList()),
    _ => throw FormatException('Unhandled Content format $jsonObject'),
  };
}

Part _parsePart(Object? jsonObject) {
  return switch (jsonObject) {
    {'text': String text} => Text(text),
    {'inlineData': {'mimeType': String _, 'data': String _}} =>
      throw UnimplementedError('inlineData content part not yet supported'),
    _ => throw FormatException('Unhandled Part format $jsonObject'),
  };
}

sealed class Part {}

final class Text implements Part {
  final String text;
  Text(this.text);
  Object toJson() => {'text': text};
}

final class Data implements Part {
  final String mimeType;
  final Uint8List bytes;
  Data(this.mimeType, this.bytes);
  Object toJson() => {
        'inlineData': {'data': base64Encode(bytes), 'mimeType': mimeType}
      };
}
