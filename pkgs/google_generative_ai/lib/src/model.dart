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

import 'api.dart';
import 'client.dart';
import 'content.dart';

final _baseUrl = Uri.https('generativelanguage.googleapis.com');
const _apiVersion = 'v1';

enum Task {
  generateContent('generateContent'),
  streamGenerateContent('streamGenerateContent'),
  countTokens('countTokens'),
  embedContent('embedContent'),
  batchEmbedContents('batchEmbedContents');

  final String _name;
  const Task(this._name);
}

/// A multimodel generative model (like Gemini).
///
/// Allows generating content, creating embeddings, and counting the number of
/// tokens in a piece of content.
final class GenerativeModel {
  final String _model;
  final List<SafetySetting> _safetySettings;
  final GenerationConfig? _generationConfig;
  final ApiClient _client;
  GenerativeModel(
      {required String model,
      required String apiKey,
      List<SafetySetting> safetySettings = const [],
      GenerationConfig? generationConfig,
      http.Client? httpClient})
      :
        // TODO: Allow `models/` prefix and strip it.
        // https://github.com/google/generative-ai-js/blob/2be48f8e5427f2f6191f24bcb8000b450715a0de/packages/main/src/models/generative-model.ts#L59
        _model = model,
        _safetySettings = safetySettings,
        _generationConfig = generationConfig,
        _client =
            HttpApiClient(model: model, apiKey: apiKey, httpClient: httpClient);

  Future<Object> _makeRequest(
      Task task, Map<String, Object?> parameters) async {
    final uri = _baseUrl.resolveUri(
        Uri(pathSegments: [_apiVersion, 'models', '$_model:${task._name}']));
    final body = utf8.encode(jsonEncode(parameters));
    final jsonString = await _client.makeRequest(uri, body);
    return jsonDecode(jsonString) as Object;
  }

  Stream<Map<String, Object?>> _streamRequest(Task task, Object parameters) {
    final uri = _baseUrl.resolveUri(
        Uri(pathSegments: [_apiVersion, 'models', '$_model:${task._name}']));
    final body = utf8.encode(jsonEncode(parameters));
    return _client.streamRequest(uri, body).map(jsonDecode).cast();
  }

  /// Returns content responding to [prompt].
  ///
  /// Calls the `generateContent` API on this model.
  ///
  ///     final response = await model.generateContent([Content.text(prompt)]);
  ///     print(response.text);
  Future<GenerateContentResponse> generateContent(
      Iterable<Content> prompt) async {
    final parameters = {
      'contents': prompt.toList(),
      if (_safetySettings.isNotEmpty) 'safetySettings': _safetySettings,
      if (_generationConfig case final config?) 'generationConfig': config,
    };
    final response = await _makeRequest(Task.generateContent, parameters);
    return parseGenerateContentResponse(response);
  }

  /// Returns a stream of content responding to [prompt].
  ///
  /// Calls the `streamGenerateContent` API on this model.
  ///
  ///     final responses = await model.generateContent([Content.text(prompt)]);
  ///     await for (final response in responses) {
  ///       print(response.text);
  ///     }
  Stream<GenerateContentResponse> generateContentStream(
      Iterable<Content> prompt) {
    final parameters = <String, Object?>{
      'contents': prompt.toList(),
      if (_safetySettings.isNotEmpty) 'safetySettings': _safetySettings,
      if (_generationConfig case final config?) 'generationConfig': config,
    };
    final response = _streamRequest(Task.streamGenerateContent, parameters);
    return response.map(parseGenerateContentResponse);
  }

  /// Returns the total number of tokens in [content].
  ///
  /// Calls the `countTokens` API on this model.
  ///
  ///     final totalTokens =
  ///         (await model.countTokens([Content.text(prompt)])).totalTokens;
  ///     if (totalTokens > maxPromptSize) {
  ///       print('Prompt is too long!');
  ///     } else {
  ///       final response = await model.generateContent();
  ///       print(response.text);
  ///     }
  Future<CountTokensResponse> countTokens(Iterable<Content> content) async {
    final parameters = <String, Object?>{'contents': content.toList()};
    final response = await _makeRequest(Task.countTokens, parameters);
    return parseCountTokensResponse(response);
  }

  /// Returns an embedding (list of float values) representing [content].
  ///
  /// Calls the `embedContent` API on this model.
  ///
  ///     final promptEmbedding =
  ///         (await model.([Content.text(prompt)])).embedding.values;
  Future<EmbedContentResponse> embedContent(Content content,
      {TaskType? taskType, String? title}) async {
    final parameters = <String, Object?>{
      'content': content,
      if (taskType != null) 'taskType': taskType,
      if (title != null) 'title': title
    };
    final response = await _makeRequest(Task.embedContent, parameters);
    return parseEmbedContentReponse(response);
  }
}
