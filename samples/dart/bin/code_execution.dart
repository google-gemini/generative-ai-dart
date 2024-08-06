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

// Set up your API Key
//
// To use the Gemini API, you'll need an API key.
// To learn more, see the "Set up your API Key" section in the Gemini API
// quickstart:
// https://ai.google.dev/gemini-api/docs/quickstart?lang=swift#set-up-api-key
final apiKey = () {
  final apiKey = Platform.environment['GEMINI_API_KEY'];
  if (apiKey == null) {
    stderr.writeln(r'No $GEMINI_API_KEY environment variable');
    exit(1);
  }
  return apiKey;
}();

Future<void> codeExecutionBasic() async {
  // [START code_execution_basic]
  final model = GenerativeModel(
    // Specify a Gemini model appropriate for your use case
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
    tools: [Tool(codeExecution: CodeExecution())],
  );
  final prompt = 'What is the sum of the first 50 prime numbers? '
      'Generate and run code for the calculation, and make sure you get '
      'all 50.';

  final response = await model.generateContent([Content.text(prompt)]);
  print(response.text);
  // [END code_execution_basic]
}

Future<void> codeExecutionChat() async {
  // [START code_execution_chat]
  final model = GenerativeModel(
    // Specify a Gemini model appropriate for your use case
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
    tools: [Tool(codeExecution: CodeExecution())],
  );
  final chat = model.startChat();
  final prompt = 'What is the sum of the first 50 prime numbers? '
      'Generate and run code for the calculation, and make sure you get '
      'all 50.';

  final response = await chat.sendMessage(Content.text(prompt));
  print(response.text);
  // [END code_execution_chat]
}

void main() async {
  codeExecutionBasic();
  codeExecutionChat();
}
