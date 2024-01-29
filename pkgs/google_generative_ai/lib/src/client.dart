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
import 'dart:typed_data';

import 'package:http/http.dart' as http;

abstract interface class ApiClient {
  Future<String> makeRequest(Uri uri, Uint8List body);
  Stream<String> streamRequest(Uri uri, Uint8List body);
}

const _packageVersion = '0.0.1';
const _clientName = 'genai-dart/$_packageVersion';

final class HttpApiClient implements ApiClient {
  final String _apiKey;
  final http.Client? _httpClient;
  late final _headers = {
    'x-goog-api-key': _apiKey,
    'x-goog-api-client': _clientName
  };

  HttpApiClient(
      {required String model, required String apiKey, http.Client? httpClient})
      : _apiKey = apiKey,
        _httpClient = httpClient ?? http.Client();

  @override
  Future<String> makeRequest(Uri uri, Uint8List body) async {
    final response = await http.post(uri,
        headers: {..._headers, 'Content-Type': 'application/json'}, body: body);
    return utf8.decode(response.bodyBytes);
  }

  @override
  Stream<String> streamRequest(Uri uri, Uint8List body) {
    final controller = StreamController<String>();
    () async {
      uri = uri.replace(queryParameters: {'alt': 'sse'});
      final request = http.Request('POST', uri)
        ..bodyBytes = body
        ..headers.addAll(_headers)
        ..headers['Content-Type'] = 'application/json';
      final response = _httpClient == null
          ? await request.send()
          : await _httpClient.send(request);
      await response.stream
          .toStringStream()
          .transform(const LineSplitter())
          .where((line) => line.startsWith('data: '))
          .map((line) => line.substring(6))
          .pipe(controller);
    }();
    return controller.stream;
  }
}
