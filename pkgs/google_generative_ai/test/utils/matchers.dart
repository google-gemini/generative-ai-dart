import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:matcher/matcher.dart';

Matcher matchesPart(Part part) => switch (part) {
      TextPart(text: final text) =>
        isA<TextPart>().having((p) => p.text, 'text', text),
      DataPart(mimeType: final mimeType, bytes: final bytes) => isA<DataPart>()
          .having((p) => p.mimeType, 'mimeType', mimeType)
          .having((p) => p.bytes, 'bytes', bytes),
    };

Matcher matchesContent(Content content) => isA<Content>()
    .having((c) => c.role, 'role', content.role)
    .having((c) => c.parts, 'parts', content.parts.map(matchesPart).toList());

Matcher matchesCandidate(Candidate candidate) => isA<Candidate>()
    .having((c) => c.content, 'content', matchesContent(candidate.content));

Matcher matchesGeenrateContentResponse(GenerateContentResponse response) =>
    isA<GenerateContentResponse>()
        .having((r) => r.candidates, 'candidates',
            response.candidates.map(matchesCandidate).toList())
        .having(
            (r) => r.promptFeedback,
            'promptFeedback',
            response.promptFeedback == null
                ? isNull
                : throw UnimplementedError('Prompt Feedback Matching'));

Matcher matchesEmbedding(ContentEmbedding embedding) =>
    isA<ContentEmbedding>().having((e) => e.values, 'values', embedding.values);

Matcher matchesEmbedContentResponse(EmbedContentResponse response) =>
    isA<EmbedContentResponse>().having(
        (r) => r.embedding, 'embedding', matchesEmbedding(response.embedding));

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
