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
import 'function_calling.dart';

const _apiVersion = 'v1beta';
Uri _googleAIBaseUri(RequestOptions? options) => Uri.https(
    'generativelanguage.googleapis.com', options?.apiVersion ?? _apiVersion);

enum Task {
  generateContent,
  streamGenerateContent,
  countTokens,
  embedContent,
  batchEmbedContents;
}

/// Configuration for how a [GenerativeModel] makes requests.
///
/// This allows overriding the API version in use which may be required to use
/// some beta features.
final class RequestOptions {
  /// The API version used to make requests.
  ///
  /// By default the version is `v1beta`.
  /// See https://ai.google.dev/gemini-api/docs/api-versions for details.
  final String? apiVersion;
  const RequestOptions({this.apiVersion});
}

/// A multimodel generative model (like Gemini).
///
/// Allows generating content, creating embeddings, and counting the number of
/// tokens in a piece of content.
final class GenerativeModel {
  /// The full model code split into a prefix ("models" or "tunedModels") and
  /// the model name.
  final ({String prefix, String name}) _model;
  final List<SafetySetting> _safetySettings;
  final GenerationConfig? _generationConfig;
  final List<Tool>? _tools;
  final ApiClient _client;
  final Uri _baseUri;
  final Content? _systemInstruction;
  final ToolConfig? _toolConfig;

  /// Create a [GenerativeModel] backed by the generative model named [model].
  ///
  /// The [model] argument can be a model name (such as `'gemini-pro'`) or a
  /// model code (such as `'models/gemini-pro'` or `'tunedModels/my-model'`).
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
  /// concurrent requests.
  /// If the `httpClient` is omitted, a new [http.Client] is created for each
  /// request.
  ///
  /// Functions that the model may call while generating content can be passed
  /// in [tools]. Tool usage by the model can be configured with [toolConfig].
  /// Tools and tool configuration can be overridden for individual requests
  /// with arguments to [generateContent] or [generateContentStream].
  ///
  /// A [Content.system] can be passed to [systemInstruction] to give
  /// high priority instructions to the model.
  factory GenerativeModel({
    required String model,
    required String apiKey,
    List<SafetySetting> safetySettings = const [],
    GenerationConfig? generationConfig,
    List<Tool>? tools,
    http.Client? httpClient,
    RequestOptions? requestOptions,
    Content? systemInstruction,
    ToolConfig? toolConfig,
  }) =>
      GenerativeModel._withClient(
        client: HttpApiClient(apiKey: apiKey, httpClient: httpClient),
        model: model,
        safetySettings: safetySettings,
        generationConfig: generationConfig,
        baseUri: _googleAIBaseUri(requestOptions),
        tools: tools,
        systemInstruction: systemInstruction,
        toolConfig: toolConfig,
      );

  GenerativeModel._withClient({
    required ApiClient client,
    required String model,
    required List<SafetySetting> safetySettings,
    required GenerationConfig? generationConfig,
    required Uri baseUri,
    required List<Tool>? tools,
    required Content? systemInstruction,
    required ToolConfig? toolConfig,
  })  : _model = _normalizeModelName(model),
        _baseUri = baseUri,
        _safetySettings = safetySettings,
        _generationConfig = generationConfig,
        _tools = tools,
        _systemInstruction = systemInstruction,
        _toolConfig = toolConfig,
        _client = client;

  /// Returns the model code for a user friendly model name.
  ///
  /// If the model name is already a model code (contains a `/`), use the parts
  /// directly. Otherwise, return a `models/` model code.
  static ({String prefix, String name}) _normalizeModelName(String modelName) {
    if (!modelName.contains('/')) return (prefix: 'models', name: modelName);
    final parts = modelName.split('/');
    return (prefix: parts.first, name: parts.skip(1).join('/'));
  }

  Uri _taskUri(Task task) => _baseUri.replace(
      pathSegments: _baseUri.pathSegments
          .followedBy([_model.prefix, '${_model.name}:${task.name}']));

  /// Generates content responding to [prompt].
  ///
  /// Sends a "generateContent" API request for the configured model,
  /// and waits for the response.
  ///
  /// The [safetySettings], [generationConfig], [tools], and [toolConfig],
  /// override the arguments of the same name passed to the
  /// [GenerativeModel.new] constructor. Each argument, when non-null,
  /// overrides the model level configuration in its entirety.
  ///
  /// Example:
  /// ```dart
  /// final response = await model.generateContent([Content.text(prompt)]);
  /// print(response.text);
  /// ```
  Future<GenerateContentResponse> generateContent(
    Iterable<Content> prompt, {
    List<SafetySetting>? safetySettings,
    GenerationConfig? generationConfig,
    List<Tool>? tools,
    ToolConfig? toolConfig,
  }) async {
    safetySettings ??= _safetySettings;
    generationConfig ??= _generationConfig;
    tools ??= _tools;
    toolConfig ??= _toolConfig;
    final parameters = {
      'contents': prompt.map((p) => p.toJson()).toList(),
      if (safetySettings.isNotEmpty)
        'safetySettings': safetySettings.map((s) => s.toJson()).toList(),
      if (generationConfig != null)
        'generationConfig': generationConfig.toJson(),
      if (tools != null) 'tools': tools.map((t) => t.toJson()).toList(),
      if (toolConfig != null) 'toolConfig': toolConfig.toJson(),
      if (_systemInstruction case final systemInstruction?)
        'systemInstruction': systemInstruction.toJson(),
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
  /// The [safetySettings], [generationConfig], [tools], and [toolConfig],
  /// override the arguments of the same name passed to the
  /// [GenerativeModel.new] constructor. Each argument, when non-null,
  /// overrides the model level configuration in its entirety.
  ///
  /// Example:
  /// ```dart
  /// final responses = await model.generateContent([Content.text(prompt)]);
  /// await for (final response in responses) {
  ///   print(response.text);
  /// }
  /// ```
  Stream<GenerateContentResponse> generateContentStream(
    Iterable<Content> prompt, {
    List<SafetySetting>? safetySettings,
    GenerationConfig? generationConfig,
    List<Tool>? tools,
    ToolConfig? toolConfig,
  }) {
    safetySettings ??= _safetySettings;
    generationConfig ??= _generationConfig;
    tools ??= _tools;
    toolConfig ??= _toolConfig;
    final parameters = <String, Object?>{
      'contents': prompt.map((p) => p.toJson()).toList(),
      if (safetySettings.isNotEmpty)
        'safetySettings': safetySettings.map((s) => s.toJson()).toList(),
      if (generationConfig != null)
        'generationConfig': generationConfig.toJson(),
      if (tools != null) 'tools': tools.map((t) => t.toJson()).toList(),
      if (toolConfig != null) 'toolConfig': toolConfig.toJson(),
      if (_systemInstruction case final systemInstruction?)
        'systemInstruction': systemInstruction.toJson(),
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
      {TaskType? taskType, String? title, int? outputDimensionality}) async {
    final parameters = <String, Object?>{
      'content': content.toJson(),
      if (taskType != null) 'taskType': taskType.toJson(),
      if (title != null) 'title': title,
      if (outputDimensionality != null)
        'outputDimensionality': outputDimensionality,
    };
    final response =
        await _client.makeRequest(_taskUri(Task.embedContent), parameters);
    return parseEmbedContentResponse(response);
  }

  /// Creates embeddings (list of float values) representing each content in
  /// [requests].
  ///
  /// Sends a "batchEmbedContents" API request for the configured model.
  ///
  /// Example:
  /// ```dart
  /// final requests = [
  ///   EmbedContentRequest(Content.text(first)),
  ///   EmbedContentRequest(Content.text(second))
  /// ];
  /// final promptEmbeddings =
  ///     (await model.embedContent(requests)).embedding.values;
  /// ```
  Future<BatchEmbedContentsResponse> batchEmbedContents(
      Iterable<EmbedContentRequest> requests) async {
    final parameters = {
      'requests': requests
          .map((r) => r.toJson(defaultModel: '${_model.prefix}/${_model.name}'))
          .toList()
    };
    final response = await _client.makeRequest(
        _taskUri(Task.batchEmbedContents), parameters);
    return parseBatchEmbedContentsResponse(response);
  }
}

/// Creates a model with an overridden [ApiClient] for testing.
///
/// Package private test-only method.
GenerativeModel createModelWithClient({
  required String model,
  required ApiClient client,
  List<SafetySetting> safetySettings = const [],
  GenerationConfig? generationConfig,
  RequestOptions? requestOptions,
  Content? systemInstruction,
  List<Tool>? tools,
  ToolConfig? toolConfig,
}) =>
    GenerativeModel._withClient(
      client: client,
      model: model,
      safetySettings: safetySettings,
      generationConfig: generationConfig,
      baseUri: _googleAIBaseUri(requestOptions),
      systemInstruction: systemInstruction,
      tools: tools,
      toolConfig: toolConfig,
    );

/// Creates a model with an overridden base URL to communicate with a different
/// backend.
///
/// Used from a `src/` import in the Vertex AI SDK.
// TODO: https://github.com/google/generative-ai-dart/issues/111 - Changes to
// this API need to be coordinated with the vertex AI SDK.
GenerativeModel createModelWithBaseUri({
  required String model,
  required String apiKey,
  required Uri baseUri,
  FutureOr<Map<String, String>> Function()? requestHeaders,
  List<SafetySetting> safetySettings = const [],
  GenerationConfig? generationConfig,
  List<Tool>? tools,
  Content? systemInstruction,
  ToolConfig? toolConfig,
}) =>
    GenerativeModel._withClient(
      client: HttpApiClient(apiKey: apiKey, requestHeaders: requestHeaders),
      model: model,
      safetySettings: safetySettings,
      generationConfig: generationConfig,
      baseUri: baseUri,
      systemInstruction: systemInstruction,
      tools: tools,
      toolConfig: toolConfig,
    );
