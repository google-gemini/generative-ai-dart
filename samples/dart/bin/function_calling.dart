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
    model: 'gemini-1.5-pro-latest',
    apiKey: apiKey,
    tools: [
      Tool(functionDeclarations: [
        FunctionDeclaration(
            'fetchCurrentWeather',
            'Returns the weather in a given location.',
            Schema(SchemaType.object, properties: {
              'location':
                  Schema.string(description: 'A location name, like "London".'),
            }, requiredProperties: [
              'location'
            ]))
      ])
    ],
  );

  final prompt =
      "I'm trying to decide whether to go to London or Zurich this weekend. "
      'How hot are those cities? How about Singapore? Or maybe Tokyo. '
      'I want to go somewhere not that cold but not too hot either. '
      'Suggest a destination.';
  final content = [Content.text(prompt)];
  var response = await model.generateContent(content);

  List<FunctionCall> functionCalls;
  while ((functionCalls = response.functionCalls.toList()).isNotEmpty) {
    var responses = <FunctionResponse>[
      for (final functionCall in functionCalls)
        _dispatchFunctionCall(functionCall)
    ];
    content
      ..add(response.candidates.first.content)
      ..add(Content.functionResponses(responses));
    response = await model.generateContent(content);
  }
  print('Response: ${response.text}');
}

FunctionResponse _dispatchFunctionCall(FunctionCall call) {
  final result = switch (call.name) {
    'fetchCurrentWeather' => {
        'weather': _fetchWeather(WeatherRequest._parse(call.args))
      },
    _ => throw UnimplementedError('Function not implemented: ${call.name}')
  };
  return FunctionResponse(call.name, result);
}

class WeatherRequest {
  static WeatherRequest _parse(Map<String, Object?> jsonObject) =>
      switch (jsonObject) {
        {'location': final String location} => WeatherRequest(location),
        _ =>
          throw FormatException('Unhandled WeatherRequest format', jsonObject),
      };
  final String location;
  WeatherRequest(this.location);

  @override
  String toString() => {'location': location}.toString();
}

var _responseIndex = -1;
Map<String, Object?> _fetchWeather(WeatherRequest request) {
  const responses = <Map<String, Object?>>[
    {'condition': 'sunny', 'temp_c': -23.9},
    {'condition': 'extreme rainstorm', 'temp_c': 13.9},
    {'condition': 'cloudy', 'temp_c': 33.9},
    {'condition': 'moderate', 'temp_c': 19.9},
  ];
  _responseIndex = (_responseIndex + 1) % responses.length;
  return responses[_responseIndex];
}
