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

import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_generative_ai/src/model.dart';
import 'package:test/test.dart';

import 'utils/matchers.dart';
import 'utils/stub_client.dart';

void main() {
  group('GenerativeModel', () {
    const defaultModelName = 'some-model';

    (StubClient, GenerativeModel) createModel(
        [String modelName = defaultModelName]) {
      final client = StubClient();
      final model = createModelWithClient(model: modelName, client: client);
      return (client, model);
    }

    test('strips leading "models/" from model name', () async {
      final (client, model) = createModel('models/$defaultModelName');
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
        },
      );
      final response = await model.generateContent([Content.text(prompt)]);
      expect(
          response,
          matchesGenerateContentResponse(GenerateContentResponse([
            Candidate(
                Content('model', [TextPart(result)]), null, null, null, null),
          ], null)));
    });

    group('generate unary content', () {
      test('can make successful request', () async {
        final (client, model) = createModel();
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
          },
        );
        final response = await model.generateContent([Content.text(prompt)]);
        expect(
            response,
            matchesGenerateContentResponse(GenerateContentResponse([
              Candidate(
                  Content('model', [TextPart(result)]), null, null, null, null),
            ], null)));
      });


      test('can override safety settings', () async {
        final (client, model) = createModel();
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
            ],
            'safetySettings': [
              {
                'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
                'threshold': 'BLOCK_ONLY_HIGH'
              }
            ],
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
          },
        );
        final response = await model.generateContent([
          Content.text(prompt)
        ], safetySettings: [
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high)
        ]);
        expect(
            response,
            matchesGenerateContentResponse(GenerateContentResponse([
              Candidate(
                  Content('model', [TextPart(result)]), null, null, null, null),
            ], null)));
      });

      test('can override generation config', () async {
        final (client, model) = createModel();
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
            ],
            'generationConfig': {
              'stopSequences': ['a']
            },
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
          },
        );
        final response = await model.generateContent([Content.text(prompt)],
            generationConfig: GenerationConfig(stopSequences: ['a']));
        expect(
            response,
            matchesGenerateContentResponse(GenerateContentResponse([
              Candidate(
                  Content('model', [TextPart(result)]), null, null, null, null),
            ], null)));
      });
    });

    group('generate content stream', () {
      test('can make successful request', () async {
        final (client, model) = createModel();
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
          ],
        );
        final response = model.generateContentStream([Content.text(prompt)]);
        expect(
            response,
            emitsInOrder([
              for (final result in results)
                matchesGenerateContentResponse(GenerateContentResponse([
                  Candidate(Content('model', [TextPart(result)]), null, null,
                      null, null),
                ], null))
            ]));
      });

      test('can override safety settings', () async {
        final (client, model) = createModel();
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
            ],
            'safetySettings': [
              {
                'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
                'threshold': 'BLOCK_ONLY_HIGH'
              }
            ],
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
          ],
        );
        final response = model.generateContentStream([
          Content.text(prompt)
        ], safetySettings: [
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high)
        ]);
        expect(
            response,
            emitsInOrder([
              for (final result in results)
                matchesGenerateContentResponse(GenerateContentResponse([
                  Candidate(Content('model', [TextPart(result)]), null, null,
                      null, null),
                ], null))
            ]));
      });

      test('can override generation config', () async {
        final (client, model) = createModel();
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
            ],
            'generationConfig': {
              'stopSequences': ['a']
            },
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
          ],
        );
        final response = model.generateContentStream([Content.text(prompt)],
            generationConfig: GenerationConfig(stopSequences: ['a']));
        expect(
            response,
            emitsInOrder([
              for (final result in results)
                matchesGenerateContentResponse(GenerateContentResponse([
                  Candidate(Content('model', [TextPart(result)]), null, null,
                      null, null),
                ], null))
            ]));
      });
    });

    group('count tokens', () {
      test('can make successful request', () async {
        final (client, model) = createModel();
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
        final (client, model) = createModel();
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
          },
        );
        final response = await model.embedContent(Content.text(prompt));
        expect(
            response,
            matchesEmbedContentResponse(
                EmbedContentResponse(ContentEmbedding([0.1, 0.2, 0.3]))));
      });
    });
  });
}
