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

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<List<String>> _generateWords(String apiKey, String subject) async {
  final config = GenerationConfig(candidateCount: 1, temperature: 1.0);
  final model = GenerativeModel(
    model: 'gemini-1.5-pro-latest',
    apiKey: apiKey,
    generationConfig: config,
    requestOptions: RequestOptions(apiVersion: 'v1beta'),
  );
  final content = [Content.text('Create a list of 20 $subject.')];

  final response = await model.generateContent(
    content,
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: Schema.array(
        items: Schema.string(
          description: 'A single word that a player will need to guess.',
        ),
      ),
    ),
  );
  final words = jsonDecode(response.text!) as List;
  return [for (final word in words) word];
}

Future<List<(String, String)>> _generateHints(
  String apiKey,
  List<String> words,
) async {
  final config = GenerationConfig(candidateCount: 1, temperature: 0.5);
  final model = GenerativeModel(
    model: 'gemini-1.5-pro-latest',
    apiKey: apiKey,
    generationConfig: config,
    requestOptions: RequestOptions(apiVersion: 'v1beta'),
  );
  final content = [
    Content.text(
      'Create a list of descriptions for these words: $words. '
      'The descriptions should be in the same order as the words. '
      'The descriptions cannot use the word itself. '
      'The descriptions should make it easy to guess the word. '
      'Each description should be 3 words long.',
    ),
  ];

  final response = await model.generateContent(
    content,
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: Schema.array(
        items: Schema.string(
          description: 'A 3 word description of some other hidden word.',
        ),
      ),
    ),
  );
  final hints = jsonDecode(response.text!) as List;
  return [for (int i = 0; i < hints.length; ++i) (words[i], hints[i])];
}

bool guessWord(String word, String hint) {
  stdout.writeln(hint);
  stdout.write('What am I? ');

  while (true) {
    final guess = stdin.readLineSync();
    if (guess == null) {
      stdout.writeln('You missed me, I am $word');
      exit(0);
    }
    if (guess.trim().toUpperCase() == word.toUpperCase()) {
      return true;
    }
    if (guess.isEmpty) {
      stdout.writeln('You missed me, I am $word');
      return false;
    }
    stdout.write('Nope! What am I? ');
  }
}

Future<void> main(List<String> args) async {
  final apiKey = Platform.environment['GOOGLE_API_KEY'];
  if (apiKey == null) {
    stderr.writeln(r'No $GOOGLE_API_KEY environment variable');
    exit(1);
  }

  final parser = ArgParser();
  parser.addOption('subject',
      defaultsTo: 'common nouns', help: 'the theme of the quiz');
  final parsedArgs = parser.parse(args);

  final words = await _generateWords(apiKey, parsedArgs['subject']);
  words.shuffle();
  final hints = await _generateHints(apiKey, words);

  final start = DateTime.now();
  var got = 0;
  while (hints.isNotEmpty) {
    final (word, prompt) = hints.removeLast();
    if (guessWord(word, prompt)) got += 1;
  }
  final end = DateTime.now();
  stdout.writeln('Got $got of ${words.length} in '
      '${end.difference(start).inSeconds} seconds');
}
