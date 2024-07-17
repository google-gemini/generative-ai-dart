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

Future<void> tokensTextOnly() async {
  // [START tokens_text_only]
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
  );
  final prompt = 'The quick brown fox jumps over the lazy dog.';
  final tokenCount = await model.countTokens([Content.text(prompt)]);
  print('Total tokens: ${tokenCount.totalTokens}');
  // [END tokens_text_only]
}

Future<void> tokensChat() async {
  // [START tokens_chat]
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
  );
  final chat = model.startChat(history: [
    Content.text('Hi my name is Bob'),
    Content.model([TextPart('Hi Bob!')])
  ]);
  var tokenCount = await model.countTokens(chat.history);
  print('Total tokens: ${tokenCount.totalTokens}');

  final response = await chat.sendMessage(Content.text(
      'In one sentence, explain how a computer works to a young child.'));
  if (response.usageMetadata case final usage?) {
    print('Prompt: ${usage.promptTokenCount}, '
        'Candidates: ${usage.candidatesTokenCount}, '
        'Total: ${usage.totalTokenCount}');
  }

  tokenCount = await model.countTokens(
      [...chat.history, Content.text('What is the meaning of life?')]);
  print('Total tokens: ${tokenCount.totalTokens}');
  // [END tokens_chat]
}

Future<void> tokensMultimodalImageInline() async {
  // [START tokens_multimodal_image_inline]
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
  );

  Future<DataPart> fileToPart(String mimeType, String path) async {
    return DataPart(mimeType, await File(path).readAsBytes());
  }

  final prompt = 'Tell me about this image';
  final image = await fileToPart('image/jpeg', 'resources/organ.jpg');
  final content = Content.multi([TextPart(prompt), image]);

  // An image's display size does not affet its token count.
  // Optionally, you can call `countTokens` for the prompt and file separately.
  final tokenCount = await model.countTokens([content]);
  print('Total tokens: ${tokenCount.totalTokens}');

  final response = await model.generateContent([content]);
  if (response.usageMetadata case final usage?) {
    print('Prompt: ${usage.promptTokenCount}, '
        'Candidates: ${usage.candidatesTokenCount}, '
        'Total: ${usage.totalTokenCount}');
  }
  // [END tokens_multimodal_image_inline]
}

Future<void> tokensSystemInstructions() async {
  // [START tokens_system_instructions]
  var model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
  );
  final prompt = 'The quick brown fox jumps over the lazy dog.';

  // The total token count includes everything sent in the `generateContent`
  // request.
  var tokenCount = await model.countTokens([Content.text(prompt)]);
  print('Total tokens: ${tokenCount.totalTokens}');
  model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
    systemInstruction: Content.system('You are a cat. Your name is Neko.'),
  );
  tokenCount = await model.countTokens([Content.text(prompt)]);
  print('Total tokens: ${tokenCount.totalTokens}');
  // [END tokens_system_instructions]
}

Future<void> tokensTools() async {
  // [START tokens_tools]
  var model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
  );
  final prompt = 'I have 57 cats, each owns 44 mittens, '
      'how many mittens is that in total?';

  // The total token count includes everything sent in the `generateContent`
  // request.
  var tokenCount = await model.countTokens([Content.text(prompt)]);
  print('Total tokens: ${tokenCount.totalTokens}');
  final binaryFunction = Schema.object(
    properties: {
      'a': Schema.number(nullable: false),
      'b': Schema.number(nullable: false)
    },
    requiredProperties: ['a', 'b'],
  );

  model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: apiKey,
    tools: [
      Tool(functionDeclarations: [
        FunctionDeclaration('add', 'returns a + b', binaryFunction),
        FunctionDeclaration('subtract', 'returns a - b', binaryFunction),
        FunctionDeclaration('multipley', 'returns a * b', binaryFunction),
        FunctionDeclaration('divide', 'returns a / b', binaryFunction)
      ])
    ],
  );
  tokenCount = await model.countTokens([Content.text(prompt)]);
  print('Total tokens: ${tokenCount.totalTokens}');
  // [END tokens_tools]
}

void main() async {
  await tokensTextOnly();
  await tokensChat();
  await tokensMultimodalImageInline();
  await tokensSystemInstructions();
  await tokensTools();
}
