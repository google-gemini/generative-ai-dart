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
import 'dart:math';
import 'dart:typed_data';

(String boundary, Uint8List requestBytes) formatMultipartRelated(
    {String? name,
    String? displayName,
    required String mimeType,
    required Uint8List fileBytes}) {
  final boundary = _boundaryString();
  final separator = '--$boundary';
  final close = utf8.encode('\r\n--$boundary--\r\n');
  final metadata = <String>[
    separator,
    'Content-Type: application/json',
    '',
    jsonEncode({
      'file': {
        if (name != null && name.isNotEmpty) 'name': name,
        if (displayName != null && displayName.isNotEmpty)
          'displayName': displayName,
      }
    }),
    separator,
    'Content-Type: $mimeType',
    '',
    ''
  ].join('\r\n');
  return (
    boundary,
    Uint8List.fromList([...utf8.encode(metadata), ...fileBytes, ...close]),
  );
}

final Random _random = Random();

/// Returns a randomly-generated multipart boundary string
String _boundaryString() {
  /// The total length of the multipart boundaries used when building the
  /// request body.
  ///
  /// According to http://tools.ietf.org/html/rfc1341.html, this can't be longer
  /// than 70.
  const boundaryLength = 70;
  final prefix = 'dart-http-boundary-';
  final list = List<int>.generate(
      boundaryLength - prefix.length,
      (index) =>
          _boundaryCharacters[_random.nextInt(_boundaryCharacters.length)],
      growable: false);
  return '$prefix${String.fromCharCodes(list)}';
}

/// All character codes that are valid in multipart boundaries.
///
/// This is the intersection of the characters allowed in the `bcharsnospace`
/// production defined in [RFC 2046][] and those allowed in the `token`
/// production defined in [RFC 1521][].
///
/// [RFC 2046]: http://tools.ietf.org/html/rfc2046#section-5.1.1.
/// [RFC 1521]: https://tools.ietf.org/html/rfc1521#section-4
const List<int> _boundaryCharacters = <int>[
  43, 95, 45, 46, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, //
  69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86,
  87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108,
  109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122
];
