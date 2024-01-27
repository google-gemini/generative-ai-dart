import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_generative_ai/src/model.dart';
import 'package:test/test.dart';

import 'utils/stub_client.dart';
import 'utils/matchers.dart';

void main() {
  group('GenerativeModel', () {
    late GenerativeModel model;
    late StubClient client;
    const modelName = 'some-model';

    setUp(() {
      client = StubClient();
      model = createModelwithClient(model: modelName, client: client);
    });

    group('generate unary content', () {
      test('can make successful request', () async {
        final prompt = 'Some prompt';
        final result = 'Some response';
        client.stub(
            Uri.parse('https://generativelanguage.googleapis.com/v1/'
                'models/some-model:generateContent'),
            {
              'contents': [
                {
                  'role': 'user',
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ]
            },
            {
              'candidates': [
                {
                  'content': {
                    'role': 'model',
                    'parts': [
                      {'text': result}
                    ]
                  }
                }
              ]
            });
        final response = await model.generateContent([Content.text(prompt)]);
        expect(
            response,
            matchesGeenrateContentResponse(GenerateContentResponse([
              Candidate(
                  Content('model', [TextPart(result)]), null, null, null, null),
            ], null)));
      });
    });

    group('generate content stream', () {
      test('can make successful request', () async {
        final prompt = 'Some prompt';
        final results = {'First response', 'Second Response'};
        client.stubStream(
            Uri.parse('https://generativelanguage.googleapis.com/v1/'
                'models/some-model:streamGenerateContent'),
            {
              'contents': [
                {
                  'role': 'user',
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ]
            },
            [
              for (final result in results)
                {
                  'candidates': [
                    {
                      'content': {
                        'role': 'model',
                        'parts': [
                          {'text': result}
                        ]
                      }
                    }
                  ]
                }
            ]);
        final response = model.generateContentStream([Content.text(prompt)]);
        expect(
            response,
            emitsInOrder([
              for (final result in results)
                matchesGeenrateContentResponse(GenerateContentResponse([
                  Candidate(Content('model', [TextPart(result)]), null, null,
                      null, null),
                ], null))
            ]));
      });
    });

    group('count tokens', () {
      test('can make successful request', () async {
        final prompt = 'Some prompt';
        client.stub(
            Uri.parse('https://generativelanguage.googleapis.com/v1/'
                'models/some-model:countTokens'),
            {
              'contents': [
                {
                  'role': 'user',
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ]
            },
            {
              'totalTokens': 2
            });
        final response = await model.countTokens([Content.text(prompt)]);
        expect(response, matchesCountTokensResponse(CountTokensResponse(2)));
      });
    });

    group('embed content', () {
      test('can make successful request', () async {
        final prompt = 'Some prompt';
        client.stub(
            Uri.parse('https://generativelanguage.googleapis.com/v1/'
                'models/some-model:embedContent'),
            {
              'content': {
                'role': 'user',
                'parts': [
                  {'text': prompt}
                ]
              }
            },
            {
              'embedding': {
                'values': [0.1, 0.2, 0.3]
              }
            });
        final response = await model.embedContent(Content.text(prompt));
        expect(
            response,
            matchesEmbedContentResponse(
                EmbedContentResponse(ContentEmbedding([0.1, 0.2, 0.3]))));
      });
    });
  });
}
