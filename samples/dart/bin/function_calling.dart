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

import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  final apiKey = Platform.environment['GOOGLE_API_KEY'];
  if (apiKey == null) {
    stderr.writeln(r'No $GOOGLE_API_KEY environment variable');
    exit(1);
  }
  final model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
      tools: [
        Tool(functionDeclarations: [
          FunctionDeclaration(
              'fetchCurrentWeather',
              'Returns the weather in a given location.',
              Schema(SchemaType.object, properties: {
                'location': Schema(SchemaType.string),
                'unit': Schema(SchemaType.string,
                    enumValues: ['celcius', 'farenheit'])
              }, requiredProperties: [
                'location'
              ]))
        ])
      ],
      requestOptions: RequestOptions(apiVersion: 'v1beta'));

  final prompt = 'What is the weather in Seattle?';
  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);

  final functionCalls =
      response.candidates.first.content.parts.whereType<FunctionCall>();
  if (functionCalls.isEmpty) {
    print('No function calls.');
    print(response.text);
  } else if (functionCalls.length > 1) {
    print('Too many function calls.');
    print(response.text);
  } else {
    content
      ..add(response.candidates.first.content)
      ..add(Content.functionResponse(
          'fetchCurrentWeather', {'weather': 'rainy'}));
    final nextResponse = await model.generateContent(content);
    print('Response: ${nextResponse.text}');
  }
}
