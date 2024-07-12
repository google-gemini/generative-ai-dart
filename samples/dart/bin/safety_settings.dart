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

Future<void> safetySettings() async {
  // [START safety_settings]
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
  );
  final prompt = 'I support Martians Soccer Club and I think '
      'Jupiterians Football Club sucks! Write an ironic phrase telling '
      'them how I feel about them.';

  final response = await model.generateContent(
    [Content.text(prompt)],
    safetySettings: [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.low)
    ],
  );
  try {
    print(response.text);
  } catch (e) {
    print(e);
    for (final SafetyRating(:category, :probability)
        in response.candidates.first.safetyRatings!) {
      print('Safety Rating: $category - $probability');
    }
  }
  // [END safety_settings]
}

Future<void> safetySettingsMulti() async {
  // [START safety_settings_multi]
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
  );
  final prompt = 'I support Martians Soccer Club and I think '
      'Jupiterians Football Club sucks! Write an ironic phrase telling '
      'them how I feel about them.';

  final response = await model.generateContent(
    [Content.text(prompt)],
    safetySettings: [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.low),
    ],
  );
  try {
    print(response.text);
  } catch (e) {
    print(e);
    for (final SafetyRating(:category, :probability)
        in response.candidates.first.safetyRatings!) {
      print('Safety Rating: $category - $probability');
    }
  }
  // [END safety_settings_multi]
}

void main() async {
  await safetySettings();
  await safetySettingsMulti();
}
