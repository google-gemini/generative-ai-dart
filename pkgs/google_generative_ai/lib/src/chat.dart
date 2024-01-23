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

import 'package:pool/pool.dart';

import 'api.dart';
import 'content.dart';
import 'model.dart';

/// A back-and-forth chat with a generative model.
///
/// Records messages sent and received in [history]. The history will always
/// record the content from the first candidate in the
/// [GenerateContentResponse], other candidates may be available on the returned
/// response.
final class ChatSession {
  final Future<GenerateContentResponse> Function(Iterable<Content> content)
      _generateContent;
  final Stream<GenerateContentResponse> Function(Iterable<Content> content)
      _generateContentStream;

  final _pool = Pool(1);

  final List<Content> _history;

  ChatSession._(
      this._generateContent, this._generateContentStream, this._history);

  /// The content that has been successfully sent to, or received from, the
  /// generative model.
  ///
  /// If there are outstanding requests from calls to [sendMessage] or
  /// [sendMessageStream] they will not be reflected in the history. Messages
  /// without a candidate in the response are not recorded in history, including
  /// the message sent to the model.
  Iterable<Content> get history => _history;

  /// Send [message] to the model as a continuation of the chat [history].
  ///
  /// Prepends the history to the request and uses the provided model to
  /// generate new content.
  ///
  /// When there are no candidates in the response the [message] and response
  /// are ignored and will not be recorded in the [history].
  ///
  /// Waits for any ongoing or pending requests to [sendMessage] or
  /// [sendMessageStream] to complete before generating new content.
  /// Successesful messages and responses for ongoing or pending requests will
  /// be reflected in the history sent for this message.
  Future<GenerateContentResponse> sendMessage(Content message) async {
    final resource = await _pool.request();
    try {
      final response = await _generateContent([..._history, message]);
      if (response.candidates case [final candidate, ...]) {
        _history.add(message);
        // TODO: Append role?
        _history.add(candidate.content);
      }
      return response;
    } finally {
      resource.release();
    }
  }

  /// Send [message] to the model as a continuation of the chat [history] and
  /// read the response in a stream.
  ///
  /// Prepends the history to the request and uses the provided model to
  /// generate new content.
  ///
  /// When there are no candidates in any response in the stream the [message]
  /// and responses are ignored and will not be recorded in the [history].
  ///
  /// Waits for any ongoing or pending requests to [sendMessage] or
  /// [sendMessageStream] to complete before generating new content.
  /// Successesful messages and responses for ongoing or pending requests will
  /// be reflected in the history sent for this message.
  ///
  /// Waits to read the entire streamed response before recording the message
  /// and response and allow pending messages to be sent.
  Stream<GenerateContentResponse> sendMessageStream(Content message) async* {
    final resource = await _pool.request();
    try {
      final responses = _generateContentStream([..._history, message]);
      final content = <Content>[];
      await for (final response in responses) {
        if (response.candidates case [final candidate, ...]) {
          content.add(candidate.content);
        }
        yield response;
      }
      if (content.isNotEmpty) {
        _history.add(message);
        _history.add(_aggregate(content));
      }
    } finally {
      resource.release();
    }
  }
}

Content _aggregate(Iterable<Content> content) {
  assert(content.isNotEmpty);
  final role = content.first.role ?? 'model';
  final textBuffer = StringBuffer();
  final parts = <Part>[];
  void addBufferedText() {
    if (textBuffer.isNotEmpty) {
      parts.add(Text(textBuffer.toString()));
      textBuffer.clear();
    }
  }

  for (final content in content) {
    for (final part in content.parts) {
      switch (part) {
        case Text(:final text):
          textBuffer.write(text);
        case Data():
          addBufferedText();
          parts.add(part);
      }
    }
  }
  addBufferedText();
  return Content(role, parts);
}

extension StartChatExtension on GenerativeModel {
  /// Returns a [ChatSession] that will use this model to respond to messages.
  ///
  ///     final chat = model.startChat();
  ///     final response = await chat.sendMessage(Content.text('Hello there.'));
  ///     print(response.text);
  ChatSession startChat({List<Content>? history}) =>
      ChatSession._(generateContent, generateContentStream, history ?? []);
}
