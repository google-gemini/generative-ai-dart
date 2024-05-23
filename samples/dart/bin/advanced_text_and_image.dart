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

import 'util/resource.dart';

void main() async {
  final apiKey = Platform.environment['GOOGLE_API_KEY'];
  if (apiKey == null) {
    stderr.writeln(r'No $GOOGLE_API_KEY environment variable');
    exit(1);
  }
  final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      generationConfig: GenerationConfig(temperature: 0));
  final prompt =
      'What do you see? Use lists. Start with a headline for each image.';
  print('Prompt: $prompt');

  final (catBytes, sconeBytes) = await (
    readResource('cat.jpg'),
    readResource('scones.jpg'),
  ).wait;
  final content = [
    Content.multi([
      TextPart(prompt),
      // The only accepted mime types are image/*.
      DataPart('image/jpeg', catBytes),
      DataPart('image/jpeg', sconeBytes),
    ])
  ];
  // final tokenCount = await model.countTokens(content);
  // print('Token count: ${tokenCount.totalTokens}');

  final responses = model.generateContentStream(content);
  await for (final response in responses) {
    stdout.write(response.text);
  }
  stdout.writeln();
}
