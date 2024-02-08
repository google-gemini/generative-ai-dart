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
import 'package:google_generative_ai/src/model.dart';
import 'package:test/test.dart';

import 'utils/matchers.dart';
import 'utils/stub_client.dart';

void main() {
  group('Chat', () {
    const defaultModelName = 'some-model';

    (StubClient, GenerativeModel) createModel(
        [String modelName = defaultModelName]) {
      final client = StubClient();
      final model = createModelWithClient(model: modelName, client: client);
      return (client, model);
    }

    test('includes chat history in prompt', () async {
      final (client, model) = createModel('models/$defaultModelName');
      final chat = model.startChat(history: [
        Content.text('Hi!'),
        Content.model([TextPart('Hello, how can I help you today?')])
      ]);
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
                {'text': 'Hi!'}
              ]
            },
            {
              'role': 'model',
              'parts': [
                {'text': 'Hello, how can I help you today?'}
              ]
            },
            {
              'role': 'user',
              'parts': [
                {'text': prompt}
              ]
            },
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
      final response = await chat.sendMessage(Content.text(prompt));
      expect(
          response,
          matchesGenerateContentResponse(GenerateContentResponse([
            Candidate(
                Content('model', [TextPart(result)]), null, null, null, null),
          ], null)));
      expect(
          chat.history.last, matchesContent(response.candidates.first.content));
    });

    test('forwards safety settings', () async {
      final (client, model) = createModel('models/$defaultModelName');
      final chat = model.startChat(safetySettings: [
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high)
      ]);
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
            },
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
      final response = await chat.sendMessage(Content.text(prompt));
      expect(
          response,
          matchesGenerateContentResponse(GenerateContentResponse([
            Candidate(
                Content('model', [TextPart(result)]), null, null, null, null),
          ], null)));
    });

    test('forwards generation config', () async {
      final (client, model) = createModel('models/$defaultModelName');
      final chat = model.startChat(
          generationConfig: GenerationConfig(stopSequences: ['a']));
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
            },
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
      final response = await chat.sendMessage(Content.text(prompt));
      expect(
          response,
          matchesGenerateContentResponse(GenerateContentResponse([
            Candidate(
                Content('model', [TextPart(result)]), null, null, null, null),
          ], null)));
    });
  });
}
