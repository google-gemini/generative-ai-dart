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

final baseUrl = Uri.https('generativelanguage.googleapis.com');
const apiVersion = 'v1';

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
  /// There is no creation time check for whether the `model` string identifies
  /// a known and supported model. If not, attempts to generate content
  /// will fail.
  ///
  /// A Google Cloud [apiKey] is required for all requests.
  /// See documentation about [API keys][] for more information.
  ///
  /// [API keys]: https://cloud.google.com/docs/authentication/api-keys "Google Cloud API keys"
  ///
  /// The optional [safetySettings] and [generationConfig] can be used to
  /// control and guide the generation. See [SafetySetting] and
  /// [GenerationConfig] for details.
  ///
  /// Content creation requests are sent to a server through the [httpClient],
  /// which can be used to control, for example, the number of allowed
  /// concurrent requests. If the `httpClient` is omitted, a new [http.Client]
  /// is created for each request.
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

  /// Lists models available through the API.
  ///
  /// A Google Cloud [apiKey] is required for all requests. See documentation
  /// about [API keys][] for more information.
  ///
  /// [API keys]: https://cloud.google.com/docs/authentication/api-keys "Google Cloud API keys"
  ///
  /// [pageSize] is the maximum number of Models to return (per page).
  /// The service may return fewer models. If unspecified, at most 50 models
  /// will be returned per page. This method returns at most 1000 models per
  /// page, even if you pass a larger pageSize.
  ///
  /// [pageToken] is a page token, received from a previous [listModels] call.
  /// Provide the pageToken returned by one request as an argument to the next
  /// request to retrieve the next page.
  /// When paginating, all other parameters provided to [listModels] must match
  /// the call that provided the page token.
  ///
  /// Requests are sent to a server through the [httpClient], which can be used
  /// to control, for example, the number of allowed concurrent requests. If the
  /// `httpClient` is omitted, a new [http.Client] is created for each request.
  ///
  /// The [apiClient] is only exposed to enable testing of this method.
  static Future<ListModelsResponse> listModels({
    required String apiKey,
    int? pageSize,
    String? pageToken,
    http.Client? httpClient,
    ApiClient? apiClient,
  }) async {
    apiClient ??= HttpApiClient(apiKey: apiKey, httpClient: httpClient);
    final response = await apiClient.makeGetRequest(
      baseUrl.resolveUri(Uri(pathSegments: [apiVersion, 'models'])),
      queryParameters: {
        if (pageSize != null) 'pageSize': pageSize,
        if (pageToken != null) 'pageToken': pageToken,
      },
    );
    return ListModelsResponse.parseJson(response);
  }

  Uri _taskUri(Task task) => baseUrl.resolveUri(
      Uri(pathSegments: [apiVersion, 'models', '$_model:${task._name}']));

  /// Generates content responding to [prompt].
  ///
  /// Sends a "generateContent" API request for the configured model,
  /// and waits for the response.
  ///
  /// Example:
  /// ```dart
  /// final response = await model.generateContent([Content.text(prompt)]);
  /// print(response.text);
  /// ```
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
    return parseGenerateContentResponse(response);
  }

  /// Generates a stream of content responding to [prompt].
  ///
  /// Sends a "streamGenerateContent" API request for the configured model,
  /// and waits for the response.
  ///
  /// Example:
  /// ```dart
  /// final responses = await model.generateContent([Content.text(prompt)]);
  /// await for (final response in responses) {
  ///   print(response.text);
  /// }
  /// ```
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

  /// Counts the total number of tokens in [contents].
  ///
  /// Sends a "countTokens" API request for the configured model,
  /// and waits for the response.
  ///
  /// Example:
  /// ```dart
  /// final promptContent = [Content.text(prompt)];
  /// final totalTokens =
  ///     (await model.countTokens(promptContent)).totalTokens;
  /// if (totalTokens > maxPromptSize) {
  ///   print('Prompt is too long!');
  /// } else {
  ///   final response = await model.generateContent(promptContent);
  ///   print(response.text);
  /// }
  /// ```
  Future<CountTokensResponse> countTokens(Iterable<Content> contents) async {
    final parameters = <String, Object?>{
      'contents': contents.map((c) => c.toJson()).toList()
    };
    final response =
        await _client.makeRequest(_taskUri(Task.countTokens), parameters);
    return parseCountTokensResponse(response);
  }

  /// Creates an embedding (list of float values) representing [content].
  ///
  /// Sends a "embedContent" API request for the configured model,
  /// and waits for the response.
  ///
  /// Example:
  /// ```dart
  /// final promptEmbedding =
  ///     (await model.embedContent([Content.text(prompt)])).embedding.values;
  /// ```
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

/// Creates a model with an overridden [ApiClient] for testing.
///
/// Package private test-only method.
GenerativeModel createModelWithClient(
        {required String model,
        required ApiClient client,
        List<SafetySetting> safetySettings = const [],
        GenerationConfig? generationConfig}) =>
    GenerativeModel._withClient(
        client: client,
        model: model,
        safetySettings: safetySettings,
        generationConfig: generationConfig);
