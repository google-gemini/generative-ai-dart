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
import 'dart:typed_data';

import 'error.dart';

/// The base structured datatype containing multi-part content of a message.
final class Content {
  /// The producer of the content.
  ///
  /// Must be either 'user' or 'model'. Useful to set for multi-turn
  /// conversations, otherwise can be left blank or unset.
  final String? role;

  /// Ordered `Parts` that constitute a single message.
  ///
  /// Parts may have different MIME types.
  final List<Part> parts;

  Content(this.role, this.parts);

  static Content text(String text) => Content('user', [TextPart(text)]);
  static Content data(String mimeType, Uint8List bytes) =>
      Content('user', [DataPart(mimeType, bytes)]);
  static Content multi(Iterable<Part> parts) => Content('user', [...parts]);
  static Content model(Iterable<Part> parts) => Content('model', [...parts]);
  static Content functionResponse(
          String name, Map<String, Object?>? response) =>
      Content('function', [FunctionResponse(name, response)]);
  static Content functionResponses(Iterable<FunctionResponse> responses) =>
      Content('function', responses.toList());
  static Content system(String instructions) =>
      Content('system', [TextPart(instructions)]);

  Map<String, Object?> toJson() => {
        if (role case final role?) 'role': role,
        'parts': parts.map((p) => p.toJson()).toList()
      };
}

Content parseContent(Object jsonObject) {
  return switch (jsonObject) {
    {'parts': final List<Object?> parts} => Content(
        switch (jsonObject) {
          {'role': final String role} => role,
          _ => null,
        },
        parts.map(_parsePart).toList()),
    _ => throw unhandledFormat('Content', jsonObject),
  };
}

Part _parsePart(Object? jsonObject) {
  return switch (jsonObject) {
    {'text': final String text} => TextPart(text),
    {
      'functionCall': {
        'name': final String name,
        'args': final Map<String, Object?> args
      }
    } =>
      FunctionCall(name, args),
    {
      'functionResponse': {'name': String _, 'response': Map<String, Object?> _}
    } =>
      throw UnimplementedError('FunctionResponse part not yet supported'),
    {
      'inlineData': {
        'mimeType': final String mimeType,
        'data': final String data
      }
    } =>
      DataPart(mimeType, base64Decode(data)),
    {
      'fileData': {
        'mimeType': final String mimeType,
        'fileUri': final String fileUri
      }
    } =>
      FilePart(mimeType, Uri.parse(fileUri)),
    {
      'executableCode': {
        'language': final String language,
        'code': final String code,
      }
    } =>
      ExecutableCode(Language._parse(language), code),
    {
      'codeExecutionResult': {
        'outcome': final String outcome,
        'output': final String output,
      }
    } =>
      CodeExecutionResult(Outcome._parse(outcome), output),
    _ => throw unhandledFormat('Part', jsonObject),
  };
}

/// A datatype containing media that is part of a multi-part [Content] message.
abstract interface class Part {
  Object toJson();
}

final class TextPart implements Part {
  final String text;
  TextPart(this.text);
  @override
  Object toJson() => {'text': text};
}

/// A [Part] with the byte content of a file.
final class DataPart implements Part {
  final String mimeType;
  final Uint8List bytes;
  DataPart(this.mimeType, this.bytes);
  @override
  Object toJson() => {
        'inlineData': {'data': base64Encode(bytes), 'mimeType': mimeType}
      };
}

/// A [Part] referring to an uploaded file.
///
/// The [uri] should refer to a file uploaded to the Google AI File Service API.
final class FilePart implements Part {
  final String mimeType;
  final Uri uri;
  FilePart(this.mimeType, this.uri);
  @override
  Object toJson() => {
        'fileData': {'mimeType': mimeType, 'fileUri': '$uri'}
      };
}

/// A predicted `FunctionCall` returned from the model that contains
/// a string representing the `FunctionDeclaration.name` with the
/// arguments and their values.
final class FunctionCall implements Part {
  /// The name of the function to call.
  final String name;

  /// The function parameters and values.
  final Map<String, Object?> args;

  FunctionCall(this.name, this.args);

  @override
  // TODO: Do we need the wrapper object?
  Object toJson() => {
        'functionCall': {'name': name, 'args': args}
      };
}

final class FunctionResponse implements Part {
  /// The name of the function that was called.
  final String name;

  /// The function response.
  ///
  /// The values must be JSON compatible types; `String`, `num`, `bool`, `List`
  /// of JSON compatibles types, or `Map` from String to JSON compatible types.
  final Map<String, Object?>? response;

  FunctionResponse(this.name, this.response);

  @override
  Object toJson() => {
        'functionResponse': {'name': name, 'response': response}
      };
}

/// The code that was executed by the model to generate a response.
///
/// When code execution is enabled, the model may generate code and run it
/// during the course of generating the text response. When it does, the code
/// is included as an `ExecutableCode` in the content.
final class ExecutableCode implements Part {
  final Language language;
  final String code;

  ExecutableCode(this.language, this.code);
  @override
  Object toJson() => {
        'executable_code': {
          'langage': language.toJson(),
          'code': code,
        }
      };
}

/// The output from running an [ExecutableCode] to generate a response.
///
/// When code execution is enabled, the model may generate code and run it
/// during the course of generating the text response. When it does, the output
/// from the code is included as a `CodeExecutionResult` in the content.
final class CodeExecutionResult implements Part {
  final Outcome outcome;
  final String output;
  CodeExecutionResult(this.outcome, this.output);

  @override
  Object toJson() => {
        'code_execution_result': {
          'outcome': outcome.toJson(),
          'output': output,
        }
      };
}

/// A programming language used in an [ExecutableCode].
enum Language {
  unspecified,
  python;

  static Language _parse(Object jsonObject) => switch (jsonObject) {
        'LANGUAGE_UNSPECIFIED' => unspecified,
        'PYTHON' => python,
        _ => throw unhandledFormat('Language', jsonObject),
      };

  String toJson() => switch (this) {
        unspecified => 'LANGUAGE_UNSPECIFIED',
        python => 'PYTHON',
      };
}

/// The type of result from running an [ExecutableCode].
enum Outcome {
  unspecified,
  ok,
  failed,
  deadlineExceeded;

  static Outcome _parse(Object jsonObject) => switch (jsonObject) {
        'OUTCOME_UNSPECIFIED' => unspecified,
        'OUTCOME_OK' => ok,
        'OUTCOME_FAILED' => failed,
        'OUTCOME_DEADLINE_EXCEEDED' => deadlineExceeded,
        _ => throw unhandledFormat('Language', jsonObject),
      };

  String toJson() => switch (this) {
        unspecified => 'OUTCOME_UNSPECIFIED',
        ok => 'OUTCOME_OK',
        failed => 'OUTCOME_FAILED',
        deadlineExceeded => 'OUTCOME_DEADLINE_EXCEEDED',
      };
}
