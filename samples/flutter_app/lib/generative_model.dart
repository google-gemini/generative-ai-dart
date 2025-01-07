import 'package:google_generative_ai/google_generative_ai.dart';

class GenerativeModelHelper {
  final GenerativeModel model;

  GenerativeModelHelper(this.model);

  Future<void> analyzeCode(String code) async {
    final prompt = 'Analyze the following code for common issues: $code';
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    final suggestions = response.text;
    if (suggestions != null) {
      logSuggestions(suggestions);
    }
  }

  void logSuggestions(String suggestions) {
    print('Code Analysis Suggestions:');
    print(suggestions);
  }
}
