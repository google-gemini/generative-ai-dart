import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  group('GenerativeModel', () {
    const apiKey = 'YOUR_API_KEY';
    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );

    test('Generate boilerplate code', () async {
      final prompt = 'Generate a Flutter widget for a login form.';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      expect(response.text, isNotNull);
      expect(response.text, contains('class'));
      expect(response.text, contains('Widget'));
    });

    test('Generate repetitive structures', () async {
      final prompt = 'Generate a repetitive structure for a list of items.';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      expect(response.text, isNotNull);
      expect(response.text, contains('ListView'));
      expect(response.text, contains('ListTile'));
    });
  });
}
