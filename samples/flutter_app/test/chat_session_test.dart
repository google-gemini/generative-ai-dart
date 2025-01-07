import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_generative_ai/src/model.dart';

void main() {
  group('ChatSession', () {
    const apiKey = 'YOUR_API_KEY';
    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );

    test('includes chat history in prompt', () async {
      final chat = model.startChat(history: [
        Content.text('Hi!'),
        Content.model([TextPart('Hello, how can I help you today?')]),
      ]);
      final prompt = 'Some prompt';
      final response = await chat.sendMessage(Content.text(prompt));

      expect(chat.history.length, 4);
      expect(chat.history.first.text, 'Hi!');
      expect(chat.history.last.text, response.text);
    });

    test('forwards safety settings', () async {
      final chat = model.startChat(safetySettings: [
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
      ]);
      final prompt = 'Some prompt';
      final response = await chat.sendMessage(Content.text(prompt));

      expect(response.candidates.first.content.parts, isNotEmpty);
    });
  });
}
