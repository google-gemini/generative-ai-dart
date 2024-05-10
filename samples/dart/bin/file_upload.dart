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
  final fileService = FileService(apiKey: apiKey);
  final catBytes = await readResource('cat.jpg');
  final uploadResponse = await fileService.createFile('image/jpeg', catBytes,
      name: 'cat', displayName: 'Cute Cat!');

  final listResponse = await fileService.listFiles();
  print('Files: ');
  print(listResponse.files.map((f) => '${f.name}: ${f.uri}').toList());

  final model = GenerativeModel(
      model: 'gemini-pro-vision',
      apiKey: apiKey,
      requestOptions: RequestOptions(apiVersion: 'v1beta'));
  final prompt = 'What do you see?';
  print('Prompt: $prompt');

  final content = [
    Content.multi([
      TextPart(prompt),
      uploadResponse.file.asPart(),
    ])
  ];

  final response = await model.generateContent(content);
  print('Response:');
  print(response.text);
}
