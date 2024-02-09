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

const packageVersion = '0.0.1';
const clientName = 'genai-dart/$packageVersion';

// Encodes first by `json.encode`, then `utf8.encode`.
// Decodes first by `utf8.decode`, then `json.decode`.
final _utf8Json = json.fuse(utf8);

final class HttpApiClient implements ApiClient {
  final String _apiKey;
  final http.Client? _httpClient;

  HttpApiClient({required String apiKey, http.Client? httpClient})
      : _apiKey = apiKey,
        _httpClient = httpClient ?? http.Client();

  @override
  Future<Map<String, Object?>> makeRequest(
      Uri uri, Map<String, Object?> body) async {
    final response = await http.post(
      uri,
      headers: {
        'x-goog-api-key': _apiKey,
        'x-goog-api-client': clientName,
        'Content-Type': 'application/json',
      },
      body: _utf8Json.encode(body),
    );
    return _utf8Json.decode(response.bodyBytes) as Map<String, Object?>;
  }

  @override
  Stream<Map<String, Object?>> streamRequest(
      Uri uri, Map<String, Object?> body) async* {
    uri = uri.replace(queryParameters: {'alt': 'sse'});
    final request = http.Request('POST', uri)
      ..bodyBytes = _utf8Json.encode(body)
      ..headers['x-goog-api-key'] = _apiKey
      ..headers['x-goog-api-client'] = clientName
      ..headers['Content-Type'] = 'application/json';
    final response = _httpClient == null
        ? await request.send()
        : await _httpClient.send(request);
    final lines =
        response.stream.toStringStream().transform(const LineSplitter());
    await for (final line in lines) {
      const dataPrefix = 'data: ';
      if (line.startsWith(dataPrefix)) {
        final jsonText = line.substring(dataPrefix.length);
        yield jsonDecode(jsonText) as Map<String, Object?>;
      }
    }
  }
}
