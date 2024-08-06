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
  final apiKey = Platform.environment['GEMINI_API_KEY'];
  if (apiKey == null) {
    stderr.writeln(r'No $GEMINI_API_KEY environment variable');
    exit(1);
  }
  final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      safetySettings: [
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high)
      ],
      generationConfig: GenerationConfig(maxOutputTokens: 200));
  final prompt = 'Write a story about a magic backpack.';
  print('Prompt: $prompt');
  final content = [Content.text(prompt)];
  final tokenCount = await model.countTokens(content);
  print('Token count: ${tokenCount.totalTokens}');

  final response = await model.generateContent(content);
  print('Response:');
  print(response.text);
}
