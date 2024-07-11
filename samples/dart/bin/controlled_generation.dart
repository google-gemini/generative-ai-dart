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

Future<void> jsonControlledGeneration() async {
  // [START json_controlled_generation]
  final schema = Schema.array(
      description: 'List of recipes',
      items: Schema.object(properties: {
        'recipeName':
            Schema.string(description: 'Name of the recipe.', nullable: false)
      }, requiredProperties: [
        'recipeName'
      ]));

  final model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
          responseMimeType: 'application/json', responseSchema: schema));

  final prompt = 'List a few popular cookie recipes.';
  final response = await model.generateContent([Content.text(prompt)]);
  print(response.text);
  // [END json_controlled_generation]
}

Future<void> jsonNoSchema() async {
  // [START json_no_schema]
  final model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'));

  final prompt = 'List a few popular cookie recipes using this JSON schema:\n\n'
      'Recipe = {"recipeName": string}\n'
      'Return: Array<Recipe>';
  final response = await model.generateContent([Content.text(prompt)]);
  print(response.text);
  // [END json_no_schema]
}

void main() async {
  await jsonControlledGeneration();
  await jsonNoSchema();
}
