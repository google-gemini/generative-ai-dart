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

  final exchangeRateTool = FunctionDeclaration(
      'findExchangeRate',
      'Returns the exchange rate between currencies on given date.',
      Schema(SchemaType.object, properties: {
        'currency_date': Schema(SchemaType.string,
            description: 'A date in YYYY-MM-DD format or '
                'the exact value "latest" if a time period is not specified.'),
        'currency_from': Schema(SchemaType.string,
            description: 'The currency code of the currency to convert from, '
                'such as "USD".'),
        'currency_to': Schema(SchemaType.string,
            description: 'The currency code of the currency to convert to, '
                'such as "USD".')
      }));

  final model = GenerativeModel(
    // Use a model that supports function calling, like Gemini 1.0 Pro
    // See "Supported models" in the "Introduction to function calling" page.
    model: 'gemini-1.0-pro',
    apiKey: apiKey,
    tools: [
      Tool(functionDeclarations: [exchangeRateTool])
    ],
  );

  final chat = model.startChat();
  final prompt = 'How much is 50 US dollars worth in Swedish krona?';

  // Send the message to the generative model.
  var response = await chat.sendMessage(Content.text(prompt));

  final functionCalls = response.functionCalls.toList();
  // When the model response with a function call, invoke the function.
  if (functionCalls.isNotEmpty) {
    final functionCall = functionCalls.first;
    final result = switch (functionCall.name) {
      // Forward arguments to the hypothetical API.
      'findExchangeRate' => await findExchangeRate(functionCall.args),
      // Throw an exception if the model attempted to call a function that was
      // not declared.
      _ => throw UnimplementedError(
          'Function not implemented: ${functionCall.name}')
    };
    // Send the response to the model so that it can use the result to generate
    // text for the user.
    response = await chat
        .sendMessage(Content.functionResponse(functionCall.name, result));
  }
  // When the model responds with non-null text content, print it.
  if (response.text case final text?) {
    print(text);
  }
}

Future<Map<String, Object?>> findExchangeRate(
  Map<String, Object?> arguments,
) async =>
    // This hypothetical API returns a JSON such as:
    // {"base":"USD","date":"2024-04-17","rates":{"SEK": 0.091}}
    {
      'date': arguments['currency_date'],
      'base': arguments['currency_from'],
      'rates': <String, Object?>{arguments['currency_to'] as String: 0.091}
    };
