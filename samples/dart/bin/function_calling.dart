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

Future<void> functionCalling() async {
  // [START function_calling]
  // Make sure to include this import:
  // import 'package:google_generative_ai/google_generative_ai.dart';
  Map<String, Object?> setLightValues(Map<String, Object?> args) {
    return args;
  }

  final controlLightFunction = FunctionDeclaration(
      'controlLight',
      'Set the brightness and color temperature of a room light.',
      Schema.object(properties: {
        'brightness': Schema.number(
            description:
                'Light level from 0 to 100. Zero is off and 100 is full brightness.',
            nullable: false),
        'colorTemperatur': Schema.string(
            description:
                'Color temperature of the light fixture which can be `daylight`, `cool`, or `warm`',
            nullable: false),
      }));

  final functions = {controlLightFunction.name: setLightValues};
  FunctionResponse dispatchFunctionCall(FunctionCall call) {
    final function = functions[call.name]!;
    final result = function(call.args);
    return FunctionResponse(call.name, result);
  }

  final model = GenerativeModel(
    model: 'gemini-1.5-pro',
    apiKey: apiKey,
    tools: [
      Tool(functionDeclarations: [controlLightFunction])
    ],
  );

  final prompt = 'Dim the lights so the room feels cozy and warm.';
  final content = [Content.text(prompt)];
  var response = await model.generateContent(content);

  List<FunctionCall> functionCalls;
  while ((functionCalls = response.functionCalls.toList()).isNotEmpty) {
    var responses = <FunctionResponse>[
      for (final functionCall in functionCalls)
        dispatchFunctionCall(functionCall)
    ];
    content
      ..add(response.candidates.first.content)
      ..add(Content.functionResponses(responses));
    response = await model.generateContent(content);
  }
  print('Response: ${response.text}');
  // [END function_calling]
}

void main() async {
  await functionCalling();
}
