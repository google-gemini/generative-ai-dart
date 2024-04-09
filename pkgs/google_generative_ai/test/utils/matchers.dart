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

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:matcher/matcher.dart';

Matcher matchesPart(Part part) => switch (part) {
      TextPart(text: final text) =>
        // TODO: When updating min SDK remove ignore.
        // ignore: unused_result, implementation bug
        isA<TextPart>().having((p) => p.text, 'text', text),
      DataPart(mimeType: final mimeType, bytes: final bytes) => isA<DataPart>()
          .having((p) => p.mimeType, 'mimeType', mimeType)
          // TODO: When updating min SDK remove ignore.
          // ignore: unused_result, implementation bug
          .having((p) => p.bytes, 'bytes', bytes),
      FilePart(uri: final uri) => isA<FilePart>()
          // TODO: When updating min SDK remove ignore.
          // ignore: unused_result, implementation bug
          .having((p) => p.uri, 'uri', uri),
    };

Matcher matchesContent(Content content) => isA<Content>()
    .having((c) => c.role, 'role', content.role)
    .having((c) => c.parts, 'parts', content.parts.map(matchesPart).toList());

Matcher matchesCandidate(Candidate candidate) => isA<Candidate>()
    .having((c) => c.content, 'content', matchesContent(candidate.content));

Matcher matchesGenerateContentResponse(GenerateContentResponse response) =>
    isA<GenerateContentResponse>()
        .having((r) => r.candidates, 'candidates',
            response.candidates.map(matchesCandidate).toList())
        .having(
            (r) => r.promptFeedback,
            'promptFeedback',
            response.promptFeedback == null
                ? isNull
                : matchesPromptFeedback(response.promptFeedback!));

Matcher matchesPromptFeedback(PromptFeedback promptFeedback) =>
    isA<PromptFeedback>()
        .having((p) => p.blockReason, 'blockReason', promptFeedback.blockReason)
        .having((p) => p.blockReasonMessage, 'blockReasonMessage',
            promptFeedback.blockReasonMessage)
        .having(
            (p) => p.safetyRatings,
            'safetyRatings',
            unorderedMatches(
                promptFeedback.safetyRatings.map(matchesSafetyRating)));

Matcher matchesSafetyRating(SafetyRating safetyRating) => isA<SafetyRating>()
    .having((s) => s.category, 'category', safetyRating.category)
    .having((s) => s.probability, 'probability', safetyRating.probability);

Matcher matchesEmbedding(ContentEmbedding embedding) =>
    isA<ContentEmbedding>().having((e) => e.values, 'values', embedding.values);

Matcher matchesEmbedContentResponse(EmbedContentResponse response) =>
    isA<EmbedContentResponse>().having(
        (r) => r.embedding, 'embedding', matchesEmbedding(response.embedding));

Matcher matchesBatchEmbedContentsResponse(
        BatchEmbedContentsResponse response) =>
    isA<BatchEmbedContentsResponse>().having((r) => r.embeddings, 'embeddings',
        response.embeddings.map(matchesEmbedding));

Matcher matchesCountTokensResponse(CountTokensResponse response) =>
    isA<CountTokensResponse>()
        .having((r) => r.totalTokens, 'totalTokens', response.totalTokens);

Matcher matchesRequest(http.Request request) => isA<http.Request>()
    .having((r) => r.headers, 'headers', request.headers)
    .having((r) => r.method, 'method', request.method)
    .having((r) => r.bodyBytes, 'bodyBytes', request.bodyBytes)
    .having((r) => r.url, 'url', request.url);

Matcher matchesBaseRequest(http.BaseRequest request) => isA<http.BaseRequest>()
    .having((r) => r.headers, 'headers', request.headers)
    .having((r) => r.method, 'method', request.method)
    .having((r) => r.url, 'url', request.url);
