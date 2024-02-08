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

import 'package:http/http.dart' as http;

import 'api.dart';
import 'client.dart';
import 'content.dart';
import 'error.dart';

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

  /// Create a [GenerativeModel] backed by the generative model named [model].
  ///
  /// The [model] argument can be a model name (such as `'gemini-pro'`) or a
  /// model code (such as `'models/gemini-pro'`).
  ///
  /// A default [http.Client] will be created for each request.
  /// Pass a [httpClient] to override with a custom client instance.
  factory GenerativeModel({
    required String model,
    required String apiKey,
    List<SafetySetting> safetySettings = const [],
    GenerationConfig? generationConfig,
    http.Client? httpClient,
  }) =>
      GenerativeModel._withClient(
          client: HttpApiClient(apiKey: apiKey, httpClient: httpClient),
          model: model,
          safetySettings: safetySettings,
          generationConfig: generationConfig);

  GenerativeModel._withClient({
    required ApiClient client,
    required String model,
    required List<SafetySetting> safetySettings,
    required GenerationConfig? generationConfig,
  })  : _model = _normalizeModelName(model),
        _safetySettings = safetySettings,
        _generationConfig = generationConfig,
        _client = client;

  static const _modelsPrefix = 'models/';
  static String _normalizeModelName(String modelName) =>
      modelName.startsWith(_modelsPrefix)
          ? modelName.substring(_modelsPrefix.length)
          : modelName;

  Uri _taskUri(Task task) => _baseUrl.resolveUri(
      Uri(pathSegments: [_apiVersion, 'models', '$_model:${task._name}']));

  /// Returns content responding to [prompt].
  ///
  /// Calls the `generateContent` API on this model.
  ///
  ///     final response = await model.generateContent([Content.text(prompt)]);
  ///     print(response.text);
  Future<GenerateContentResponse> generateContent(Iterable<Content> prompt,
      {List<SafetySetting>? safetySettings,
      GenerationConfig? generationConfig}) async {
    safetySettings ??= _safetySettings;
    generationConfig ??= _generationConfig;
    final parameters = {
      'contents': prompt.map((p) => p.toJson()).toList(),
      if (safetySettings.isNotEmpty)
        'safetySettings': safetySettings.map((s) => s.toJson()).toList(),
      if (generationConfig case final config?)
        'generationConfig': config.toJson(),
    };
    final response =
        await _client.makeRequest(_taskUri(Task.generateContent), parameters);
    try {
      return parseGenerateContentResponse(response);
    } on FormatException {
      if (response case {'error': final Object error}) {
        throw parseError(error);
      }
      rethrow;
    }
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
      Iterable<Content> prompt,
      {List<SafetySetting>? safetySettings,
      GenerationConfig? generationConfig}) {
    safetySettings ??= _safetySettings;
    generationConfig ??= _generationConfig;
    final parameters = <String, Object?>{
      'contents': prompt.map((p) => p.toJson()).toList(),
      if (safetySettings.isNotEmpty)
        'safetySettings': safetySettings.map((s) => s.toJson()).toList(),
      if (generationConfig case final config?)
        'generationConfig': config.toJson(),
    };
    final response =
        _client.streamRequest(_taskUri(Task.streamGenerateContent), parameters);
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
    final parameters = <String, Object?>{
      'contents': content.map((c) => c.toJson()).toList()
    };
    final response =
        await _client.makeRequest(_taskUri(Task.countTokens), parameters);
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
      'content': content.toJson(),
      if (taskType != null) 'taskType': taskType.toJson(),
      if (title != null) 'title': title
    };
    final response =
        await _client.makeRequest(_taskUri(Task.embedContent), parameters);
    return parseEmbedContentResponse(response);
  }
}

/// Create a model with an overridden [ApiClient] for testing.
///
/// Package private test only method.
GenerativeModel createModelwithClient(
        {required String model,
        required ApiClient client,
        List<SafetySetting> safetySettings = const [],
        GenerationConfig? generationConfig}) =>
    GenerativeModel._withClient(
        client: client,
        model: model,
        safetySettings: safetySettings,
        generationConfig: generationConfig);
