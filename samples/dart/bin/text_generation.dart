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
  final apiKey = Platform.environment['GOOGLE_API_KEY'];
  if (apiKey == null) {
    stderr.writeln(r'No $GOOGLE_API_KEY environment variable');
    exit(1);
  }
  return apiKey;
}();

Future<void> textGenTextOnlyPrompt() async {
  // [START text_gen_text_only_prompt]
  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apiKey,
  );
  final prompt = 'Write a story about a magic backpack.';

  final response = await model.generateContent([Content.text(prompt)]);
  print(response.text);
  // [END text_gen_text_only_prompt]
}

Future<void> textGenTextOnlyPromptStreaming() async {
  // [START text_gen_text_only_prompt_streaming]
  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apiKey,
  );
  final prompt = 'Write a story about a magic backpack.';

  final responses = model.generateContentStream([Content.text(prompt)]);
  await for (final response in responses) {
    print(response.text);
  }
  // [END text_gen_text_only_prompt_streaming]
}

Future<void> textGenMultimodalOneImagePrompt() async {
  // [START text_gen_multimodal_one_image_prompt]
  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apiKey,
  );

  Future<DataPart> fileToPart(String mimeType, String path) async {
    return DataPart(mimeType, await File(path).readAsBytes());
  }

  final prompt = 'Describe how this product might be manufactured.';
  final image = await fileToPart('image/jpeg', 'resources/jetpack.jpg');

  final response = await model.generateContent([
    Content.multi([TextPart(prompt), image])
  ]);
  print(response.text);
  // [END text_gen_multimodal_one_image_prompt]
}

Future<void> textGenMultimodalOneImagePromptStreaming() async {
  // [START text_gen_multimodal_one_image_prompt_streaming]
  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apiKey,
  );

  Future<DataPart> fileToPart(String mimeType, String path) async {
    return DataPart(mimeType, await File(path).readAsBytes());
  }

  final prompt = 'Describe how this product might be manufactured.';
  final image = await fileToPart('image/jpeg', 'resources/jetpack.jpg');

  final responses = model.generateContentStream([
    Content.multi([TextPart(prompt), image])
  ]);
  await for (final response in responses) {
    print(response.text);
  }
  // [END text_gen_multimodal_one_image_prompt_streaming]
}

Future<void> textGenMultimodalMultiImagePrompt() async {
  // [START text_gen_multimodal_multi_image_prompt]
  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apiKey,
  );

  Future<DataPart> fileToPart(String mimeType, String path) async {
    return DataPart(mimeType, await File(path).readAsBytes());
  }

  final prompt = 'Write an advertising jingle showing how the product in the'
      ' first image could solve the problems shown in the second two images.';
  final images = await [
    fileToPart('image/jpeg', 'resources/jetpack.jpg'),
    fileToPart('image/jpeg', 'resources/piranha.jpg'),
    fileToPart('image/jpeg', 'resources/firefighter.jpg'),
  ].wait;

  final response = await model.generateContent([
    Content.multi([TextPart(prompt), ...images])
  ]);
  print(response.text);
  // [END text_gen_multimodal_multi_image_prompt]
}

Future<void> textGenMultimodalMultiImagePromptStreaming() async {
  // [START text_gen_multimodal_multi_image_prompt_streaming]
  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apiKey,
  );

  Future<DataPart> fileToPart(String mimeType, String path) async {
    return DataPart(mimeType, await File(path).readAsBytes());
  }

  final prompt = 'Write an advertising jingle showing how the product in the'
      ' first image could solve the problems shown in the second two images.';
  final images = await [
    fileToPart('image/jpeg', 'resources/jetpack.jpg'),
    fileToPart('image/jpeg', 'resources/piranha.jpg'),
    fileToPart('image/jpeg', 'resources/firefighter.jpg'),
  ].wait;

  final responses = model.generateContentStream([
    Content.multi([TextPart(prompt), ...images])
  ]);
  await for (final response in responses) {
    print(response.text);
  }
  // [END text_gen_multimodal_multi_image_prompt_streaming]
}

void main() async {
  await textGenTextOnlyPrompt();
  await textGenTextOnlyPromptStreaming();
  await textGenMultimodalOneImagePrompt();
  await textGenMultimodalOneImagePromptStreaming();
  await textGenMultimodalMultiImagePrompt();
  await textGenMultimodalMultiImagePromptStreaming();
}
