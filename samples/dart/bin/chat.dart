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

final apiKey = () {
  final apiKey = Platform.environment['GEMINI_API_KEY'];
  if (apiKey == null) {
    stderr.writeln(r'No $GEMINI_API_KEY environment variable');
    exit(1);
  }
  return apiKey;
}();

Future<void> chat() async {
  // [START chat]
  // Make sure to include this import:
  // import 'package:google_generative_ai/google_generative_ai.dart';
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
  );
  final chat = model.startChat(history: [
    Content.text('hello'),
    Content.model([TextPart('Great to meet you. What would you like to know?')])
  ]);
  var response =
      await chat.sendMessage(Content.text('I have 2 dogs in my house.'));
  print(response.text);
  response =
      await chat.sendMessage(Content.text('How many paws are in my house?'));
  print(response.text);
  // [END chat]
}

Future<void> chatStreaming() async {
  // [START chat_streaming]
  // Make sure to include this import:
  // import 'package:google_generative_ai/google_generative_ai.dart';
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
  );
  final chat = model.startChat(history: [
    Content.text('hello'),
    Content.model([TextPart('Great to meet you. What would you like to know?')])
  ]);
  var responses =
      chat.sendMessageStream(Content.text('I have 2 dogs in my house.'));
  await for (final response in responses) {
    print(response.text);
    print('_' * 80);
  }
  responses =
      chat.sendMessageStream(Content.text('How many paws are in my house?'));
  await for (final response in responses) {
    print(response.text);
    print('_' * 80);
  }
  // [END chat_streaming]
}

Future<void> chatStreamingWithImages() async {
  // [START chat_streaming_with_images]
  // Make sure to include this import:
  // import 'package:google_generative_ai/google_generative_ai.dart';
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
  );
  Future<DataPart> fileToPart(String mimeType, String path) async {
    return DataPart(mimeType, await File(path).readAsBytes());
  }

  final chat = model.startChat();
  var responses = chat.sendMessageStream(Content.text(
      "Hello, I'm interested in learning about musical instruments. "
      'Can I show you one?'));
  await for (final response in responses) {
    print(response.text);
    print('_' * 80);
  }
  final prompt = 'What family of instruments does this belong to?';
  final image = await fileToPart('image/jpeg', 'resources/organ.jpg');
  responses = chat.sendMessageStream(Content.multi([TextPart(prompt), image]));
  await for (final response in responses) {
    print(response.text);
    print('_' * 80);
  }
  // [END chat_streaming_with_images]
}

void main() async {
  await chat();
  await chatStreaming();
  await chatStreamingWithImages();
}
