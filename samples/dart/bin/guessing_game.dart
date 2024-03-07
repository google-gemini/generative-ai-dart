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

import 'package:google_generative_ai/google_generative_ai.dart';

final listItemExtractor = RegExp(r"((\d+\.?)|[-*])\s+(?<content>.+)");

List<String> parseList(String lst, int expectedLength) {
  final lines = LineSplitter.split(lst).toList();
  if (lines.length != expectedLength) {
    throw FormatException('Unexpected length for $lst');
  }

  final lists = <String>[];
  for (var line in lines) {
    final match = listItemExtractor.firstMatch(line);
    if (match == null) {
      throw FormatException('Unexpected list item: $line');
    }
    lists.add(match.namedGroup('content')!);
  }
  return lists;
}

Future<List<String>> getWords(String apiKey) async {
  final config = GenerationConfig(candidateCount: 1, temperature: 1.0);
  final model = GenerativeModel(
      model: 'gemini-pro', apiKey: apiKey, generationConfig: config);
  final content = [
    Content.text('Create a bullet list of 20 random common nouns.')
  ];

  final response = await model.generateContent(content);
  return parseList(response.text!, 20);
}

Future<List<(String, String)>> getHints(
    String apiKey, List<String> words) async {
  final config = GenerationConfig(candidateCount: 1, temperature: 0.5);
  final model = GenerativeModel(
      model: 'gemini-pro', apiKey: apiKey, generationConfig: config);
  final content = [
    Content.text(
        'Create a bullet list of 3 word descriptions for these words: $words. '
        'The descriptions should be in the same order as the words. '
        'The descriptions cannot use the word itself. '
        'The descriptions should make it easy to guess the word.')
  ];

  final pairs = <(String, String)>[];
  final response = await model.generateContent(content);
  final hints = parseList(response.text!, 20);

  for (int i = 0; i < hints.length; ++i) {
    pairs.add((words[i], hints[i]));
  }
  return pairs;
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

Future<void> main() async {
  final apiKey = Platform.environment['GOOGLE_API_KEY'];
  if (apiKey == null) {
    stderr.writeln(r'No $GOOGLE_API_KEY environment variable');
    exit(1);
  }
  final words = await getWords(apiKey);
  words.shuffle();
  final hints = await getHints(apiKey, words);

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
