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

Future<void> main() async {
  final apiKey = Platform.environment['GOOGLE_API_KEY'];
  if (apiKey == null) {
    stderr.writeln(r'No $GOOGLE_API_KEY environment variable');
    exit(1);
  }
  final model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
      generationConfig: GenerationConfig(maxOutputTokens: 100));
  final chat = model.startChat(history: [
    Content.text('Hello, I have 2 dogs in my house.'),
    Content.model([TextPart('Great to meet you. What would you like to know?')])
  ]);
  var message = 'How many paws are in my house?';
  print('Message: $message');
  var content = Content.text(message);
  var CountTokensResponse(:totalTokens) =
      await model.countTokens([...chat.history, content]);
  print('Token count: $totalTokens');
  var response = await chat.sendMessage(content);
  print('Response: ${response.text}');

  content = Content.text('How many noses (including mine)?');
  CountTokensResponse(:totalTokens) =
      await model.countTokens([...chat.history, content]);
  print('Token count: $totalTokens');
  response = await chat.sendMessage(content);
  print('Response: ${response.text}');

  print('Chat history:');
  for (final content in chat.history) {
    print('${content.role}:');
    for (final part in content.parts) {
      switch (part) {
        case TextPart(:final text):
          print(text);
        case _:
          print('Non text content');
      }
    }
  }
}
