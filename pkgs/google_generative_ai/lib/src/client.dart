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

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

abstract interface class ApiClient {
  Future<Map<String, Object?>> makeRequest(Uri uri, Map<String, Object?> body);
  Stream<Map<String, Object?>> streamRequest(
      Uri uri, Map<String, Object?> body);
}

const _packageVersion = '0.0.1';
const clientName = 'genai-dart/$_packageVersion';

final class HttpApiClient implements ApiClient {
  final String _apiKey;
  late final _headers = {
    'x-goog-api-key': _apiKey,
    'x-goog-api-client': clientName
  };

  HttpApiClient({required String apiKey}) : _apiKey = apiKey;

  @override
  Future<Map<String, Object?>> makeRequest(
      Uri uri, Map<String, Object?> body) async {
    final response = await http.post(
      uri,
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: utf8.encode(jsonEncode(body)),
    );
    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, Object?>;
  }

  @override
  Stream<Map<String, Object?>> streamRequest(
      Uri uri, Map<String, Object?> body) {
    final controller = StreamController<Map<String, Object?>>();
    () async {
      uri = uri.replace(queryParameters: {'alt': 'sse'});
      final request = http.Request('POST', uri)
        ..bodyBytes = utf8.encode(jsonEncode(body))
        ..headers.addAll(_headers)
        ..headers['Content-Type'] = 'application/json';
      final response = await request.send();
      await response.stream
          .toStringStream()
          .transform(const LineSplitter())
          .where((line) => line.startsWith('data: '))
          .map((line) => line.substring(6))
          .map(jsonDecode)
          .cast<Map<String, Object?>>()
          .pipe(controller);
    }();
    return controller.stream;
  }
}
