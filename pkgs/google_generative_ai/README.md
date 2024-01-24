[![package:google_generative_ai](https://github.com/google/generative-ai-dart/actions/workflows/google_generative_ai.yml/badge.svg)](https://github.com/google/generative-ai-dart/actions/workflows/google_generative_ai.yml)

The Google Generative AI SDK for Dart allows developers to use state-of-the-art
Large Language Models (LLMs) to build language applications.

## Getting Started

### Get an API key

Using the Gemini SDK requires an API key; see
https://ai.google.dev/tutorials/setup for how to create one.

### Add the package to your project

Add a dependency on the package via:

```yaml
dependencies:
  google_generative_ai:
    git:
      url: git@github.com:google/generative-ai-dart.git
      path: pkgs/google_generative_ai
      ref: main
```

And import:

```dart
import 'package:google_generative_ai/google_generative_ai.dart';
```

### Using the API

```dart
import 'package:google_generative_ai/google_generative_ai.dart';

const apiKey = ...;

void main() async {
  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  final prompt = 'Write a story about a magic backpack.';
  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);

  print(response.text);
};
```

See additional examples at
[samples/](https://github.com/google/generative-ai-dart/tree/main/samples).

## Additional documentation

You can find additional documentation for the Google AI SDKs and the Gemini
at [ai.google.dev/docs](https://ai.google.dev/docs).
