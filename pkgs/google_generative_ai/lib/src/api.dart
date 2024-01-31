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

import 'content.dart';
import 'error.dart';
import 'model.dart';

final class CountTokensResponse {
  final int totalTokens;
  CountTokensResponse(this.totalTokens);
}

final class GenerateContentResponse {
  final List<Candidate> candidates;
  final PromptFeedback? promptFeedback;
  GenerateContentResponse(this.candidates, this.promptFeedback);

  /// The text content of the first part of the first of [candidates], if any.
  ///
  /// If the prompt was blocked, or the first candidate was finished for a reason
  /// of [FinishReason.recitation] or [FinishReason.safety], accessing this text
  /// will throw a [GenerativeAIException].
  ///
  /// If the first candidate's content starts with a text part, this value is
  /// that text.
  ///
  /// If there are no candidates, or if the first candidate does not start with
  /// a text part, this value is `null`.
  String? get text {
    return switch (candidates) {
      [] => switch (promptFeedback) {
          PromptFeedback(
            :final blockReason,
            :final blockReasonMessage,
          ) =>
            throw GenerativeAIException('Reponse was blocked'
                '${blockReason != null ? ' due to $blockReason' : ''}'
                '${blockReasonMessage != null ? ': $blockReasonMessage' : ''}'),
          _ => null,
        },
      [
        Candidate(
          finishReason: (FinishReason.recitation || FinishReason.safety) &&
              final finishReason,
          :final finishMessage,
        ),
        ...
      ] =>
        throw GenerativeAIException(
          // ignore: prefer_interpolation_to_compose_strings
          'Candidate was blocked due to $finishReason' +
              (finishMessage != null && finishMessage.isNotEmpty
                  ? ': $finishMessage'
                  : ''),
        ),
      [Candidate(content: Content(parts: [TextPart(:final text)])), ...] =>
        text,
      [Candidate(), ...] => null,
    };
  }
}

final class EmbedContentResponse {
  final ContentEmbedding embedding;
  EmbedContentResponse(this.embedding);
}

/// An embedding, as defined by a list of values.
final class ContentEmbedding {
  final List<double> values;
  ContentEmbedding(this.values);
}

/// Feedback metadata of a prompt specified in a [GenerativeModel] request.
final class PromptFeedback {
  final BlockReason? blockReason;
  final String? blockReasonMessage;
  final List<SafetyRating> safetyRatings;
  PromptFeedback(this.blockReason, this.blockReasonMessage, this.safetyRatings);
}

/// Response candidate generated from a [GenerativeModel].
final class Candidate {
  final Content content;
  final List<SafetyRating>? safetyRatings;
  final CitationMetadata? citationMetadata;
  final FinishReason? finishReason;
  final String? finishMessage;
  // TODO: token count?
  Candidate(this.content, this.safetyRatings, this.citationMetadata,
      this.finishReason, this.finishMessage);
}

/// Safety rating for a piece of content.
///
/// The safety rating contains the category of harm and the harm probability
/// level in that category for a piece of content. Content is classified for
/// safety across a number of harm categories and the probability of the harm
/// classification is included here.
final class SafetyRating {
  final HarmCategory category;
  final HarmProbability probability;
  SafetyRating(this.category, this.probability);
}

/// The reason why a prompt was blocked.
enum BlockReason {
  unknown,
  unspecified,
  safety,
  other;

  @override
  String toString() => this.name;
}

enum HarmCategory {
  unknown('HARM_CATEGORY_UNSPECIFIED'),
  harassment('HARM_CATEGORY_HARASSMENT'),
  hateSpeech('HARM_CATEGORY_HATE_SPEECH'),
  sexuallyExplicit('HARM_CATEGORY_SEXUALLY_EXPLICIT'),
  dangerousContent('HARM_CATEGORY_DANGEROUS_CONTENT');

  const HarmCategory(this._jsonString);

  final String _jsonString;

  String toJson() => _jsonString;
}

enum HarmProbability {
  unknown,
  unspecified,
  negligible,
  low,
  medium,
  high,
}

/// Source attributions for a piece of content.
final class CitationMetadata {
  final List<CitationSource> citationSources;
  CitationMetadata(this.citationSources);
}

/// Citation to a source for a portion of a specific response.
final class CitationSource {
  final int? startIndex;
  final int? endIndex;
  final Uri? uri;
  final String? license;
  CitationSource(this.startIndex, this.endIndex, this.uri, this.license);
}

/// Reason why a model stopped generating tokens.
enum FinishReason {
  unknown,
  unspecified,
  stop,
  maxTokens,
  safety,
  recitation,
  other;

  @override
  String toString() => this.name;
}

/// Safety setting, affecting the safety-blocking behavior.
///
/// Passing a safety setting for a category changes the allowed proability that
/// content is blocked.
final class SafetySetting {
  final HarmCategory category;
  final HarmBlockThreshold threshold;
  SafetySetting(this.category, this.threshold);
  Object toJson() =>
      {'category': category.toJson(), 'threshold': threshold.toJson()};
}

enum HarmBlockThreshold {
  unspecified('HARM_BLOCK_THRESHOLD_UNSPECIFIED'),
  low('BLOCK_LOW_AND_ABOVE'),
  medium('BLOCK_MEDIUM_AND_ABOVE'),
  high('BLOCK_ONLY_HIGH'),
  none('BLOCK_NONE');

  final String _jsonString;
  const HarmBlockThreshold(this._jsonString);

  Object toJson() => _jsonString;
}

/// Configuration options for model generation and outputs.
final class GenerationConfig {
  final int? candidateCount;
  final List<String> stopSequences;
  final int? maxOutputTokens;
  final int? temperature;
  final int? topP;
  final int? topK;
  GenerationConfig(
      {this.candidateCount,
      this.stopSequences = const [],
      this.maxOutputTokens,
      this.temperature,
      this.topP,
      this.topK});

  Map<String, Object?> toJson() => {
        if (candidateCount case final candidateCount?)
          'candidateCount': candidateCount,
        if (stopSequences.isNotEmpty) 'stopSequences': stopSequences,
        if (maxOutputTokens case final maxOutputTokens?)
          'maxOutputTokens': maxOutputTokens,
        if (temperature case final temperature?) 'temperature': temperature,
        if (topP case final topP?) 'topP': topP,
        if (topK case final topK?) 'topK': topK,
      };
}

/// Type of task for which the embedding will be used.
enum TaskType {
  unspecified('TASK_TYPE_UNSPECIFIED'),
  retrievalQuery('RETRIEVAL_QUERY'),
  retrievalDocument('RETRIEVAL_DOCUMENT'),
  semanticSimilarity('SEMANTIC_SIMILARITY'),
  classification('CLASSIFICATION'),
  clustering('CLUSTERING');

  final String _jsonString;

  const TaskType(this._jsonString);

  Object toJson() => _jsonString;
}

GenerateContentResponse parseGenerateContentResponse(Object jsonObject) {
  return switch (jsonObject) {
    {'candidates': final List<Object?> candidates} => GenerateContentResponse(
        candidates.map(_parseCandidate).toList(),
        switch (jsonObject) {
          {'promptFeedback': final Map promptFeedback} =>
            _parsePromptFeedback(promptFeedback),
          _ => null
        }),
    _ => throw FormatException(
        'Unhandled GenerateContentResponse format: $jsonObject')
  };
}

CountTokensResponse parseCountTokensResponse(Object jsonObject) {
  return switch (jsonObject) {
    {'totalTokens': final int totalTokens} => CountTokensResponse(totalTokens),
    _ =>
      throw FormatException('Unhandled CountTokensReponse format: $jsonObject')
  };
}

EmbedContentResponse parseEmbedContentReponse(Object jsonObject) {
  return switch (jsonObject) {
    {'embedding': final Object embedding} =>
      EmbedContentResponse(_parseContentEmbedding(embedding)),
    _ => throw FormatException(
        'Unhandled EmbedContentResponse format: $jsonObject')
  };
}

Candidate _parseCandidate(Object? jsonObject) {
  return switch (jsonObject) {
    {
      'content': final Object content,
    } =>
      Candidate(
          parseContent(content),
          switch (jsonObject) {
            {'safetyRatings': final List<Object?> safetyRatings} =>
              safetyRatings.map(_parseSafetyRating).toList(),
            _ => null
          },
          switch (jsonObject) {
            {'citationMetadata': final Object citationMetadata} =>
              _parseCitationMetadata(citationMetadata),
            _ => null
          },
          switch (jsonObject) {
            {'finishReason': final Object finishReason} =>
              _parseFinishReason(finishReason),
            _ => null
          },
          switch (jsonObject) {
            {'finishMessage': final String finishMessage} => finishMessage,
            _ => null
          }),
    _ => throw FormatException('Unhandled Candidate format: $jsonObject'),
  };
}

PromptFeedback _parsePromptFeedback(Object jsonObject) {
  return switch (jsonObject) {
    {
      'safetyRatings': final List<Object?> safetyRatings,
    } =>
      PromptFeedback(
          switch (jsonObject) {
            {'blockReason': final String blockReason} =>
              _parseBlockReason(blockReason),
            _ => null,
          },
          switch (jsonObject) {
            {'blockReasonMessage': final String blockReasonMessage} =>
              blockReasonMessage,
            _ => null,
          },
          safetyRatings.map(_parseSafetyRating).toList()),
    _ => throw FormatException('Unhandled PromptFeedback format $jsonObject'),
  };
}

SafetyRating _parseSafetyRating(Object? jsonObject) {
  return switch (jsonObject) {
    {
      'category': final Object category,
      'probability': final Object probability
    } =>
      SafetyRating(
          _parseHarmCategory(category), _parseHarmProbability(probability)),
    _ => throw FormatException('Unhandled SafetyRating format $jsonObject'),
  };
}

ContentEmbedding _parseContentEmbedding(Object? jsonObject) {
  return switch (jsonObject) {
    {'values': final List values} => ContentEmbedding(<double>[
        ...values.cast<double>(),
      ]),
    _ => throw FormatException('Unhandled ContentEmbedding format $jsonObject'),
  };
}

HarmCategory _parseHarmCategory(Object jsonObject) {
  return switch (jsonObject) {
    'HARM_CATEGORY_UNSPECIFIED' => HarmCategory.unknown,
    'HARM_CATEGORY_HARASSMENT' => HarmCategory.harassment,
    'HARM_CATEGORY_HATE_SPEECH' => HarmCategory.hateSpeech,
    'HARM_CATEGORY_SEXUALLY_EXPLICIT' => HarmCategory.sexuallyExplicit,
    'HARM_CATEGORY_DANGEROUS_CONTENT' => HarmCategory.dangerousContent,
    _ => throw FormatException('Unhandled HarmCategory format $jsonObject'),
  };
}

HarmProbability _parseHarmProbability(Object jsonObject) {
  return switch (jsonObject) {
    'UNKNOWN' => HarmProbability.unknown,
    'UNSPECIFIED' => HarmProbability.unspecified,
    'NEGLIGIBLE' => HarmProbability.negligible,
    'LOW' => HarmProbability.low,
    'MEDIUM' => HarmProbability.medium,
    'HIGH' => HarmProbability.high,
    _ => throw FormatException('Unhandled HarmPropbability format $jsonObject'),
  };
}

CitationMetadata _parseCitationMetadata(Object? jsonObject) {
  return switch (jsonObject) {
    {'citationSources': final List<Object?> citationSources} =>
      CitationMetadata(citationSources.map(_parseCitationSource).toList()),
    _ => throw FormatException('Unhandled CitationMetadata format $jsonObject'),
  };
}

CitationSource _parseCitationSource(Object? jsonObject) {
  return switch (jsonObject) {
    {
      'startIndex': final int startIndex,
      'endIndex': final int endIndex,
      'uri': final String uri,
      'license': final String license,
    } =>
      CitationSource(startIndex, endIndex, Uri.parse(uri), license),
    _ => throw FormatException('Unhandled CitationSource format $jsonObject'),
  };
}

FinishReason _parseFinishReason(Object jsonObject) {
  return switch (jsonObject) {
    'UNKNOWN' => FinishReason.unknown,
    'UNSPECIFIED' => FinishReason.unspecified,
    'STOP' => FinishReason.stop,
    'MAX_TOKENS' => FinishReason.maxTokens,
    'SAFETY' => FinishReason.safety,
    'RECITATION' => FinishReason.recitation,
    'OTHER' => FinishReason.other,
    _ => throw FormatException('Unhandled FinishReason format $jsonObject'),
  };
}

BlockReason _parseBlockReason(String jsonObject) {
  return switch (jsonObject) {
    'UNKNOWN' => BlockReason.unknown,
    'UNSPECIFIED' => BlockReason.unspecified,
    'SAFETY' => BlockReason.safety,
    'OTHER' => BlockReason.other,
    _ => throw FormatException('Unhandled BlockReason format $jsonObject'),
  };
}
