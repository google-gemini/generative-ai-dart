[![package:google_generative_ai](https://github.com/google/generative-ai-dart/actions/workflows/google_generative_ai.yml/badge.svg)](https://github.com/google/generative-ai-dart/actions/workflows/google_generative_ai.yml)
[![pub package](https://img.shields.io/pub/v/google_generative_ai.svg)](https://pub.dev/packages/google_generative_ai)
[![package publisher](https://img.shields.io/pub/publisher/google_generative_ai.svg)](https://pub.dev/packages/google_generative_ai/publisher)

The Google AI Dart SDK enables developers to use Google's state-of-the-art
generative AI models (like Gemini) to build AI-powered features and
applications. This SDK supports use cases like:

-   Generate text from text-only input
-   Generate text from text-and-images input (multimodal)
-   Build multi-turn conversations (chat)
-   Embedding

> [!CAUTION]
> **Using the Google AI SDK for Dart (Flutter) to call the Google AI Gemini API
> directly from your app is recommended for prototyping only.** If you plan to
> enable billing, we strongly recommend that you use the SDK to call the Google
> AI Gemini API only server-side to keep your API key safe. You risk potentially
> exposing your API key to malicious actors if you embed your API key directly
> in your mobile or web app or fetch it remotely at runtime.

## Getting started

### Get an API key

Using the Google AI Dart SDK requires an API key; see
https://ai.google.dev/tutorials/setup for how to create one.

### Add the package to your project

Add a dependency on the `package:google_generative_ai` package like so:

```shell
dart pub add google_generative_ai
```

or:

```shell
flutter pub add google_generative_ai
```

Additionally, import:

```dart
import 'package:google_generative_ai/google_generative_ai.dart';
```

### Use the API

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

For detailed instructions, you can find a quickstart for the Google AI Dart SDK
in the Google documentation: http://ai.google.dev/tutorials/dart_quickstart.
This quickstart describes how to add your API key and the SDK to your app,
initialize the model, and then call the API to access the model. It also
describes some additional use cases and features, like streaming, embedding,
counting tokens, and controlling responses.

## Additional documentation

You can find additional documentation for the Google AI SDKs and the Gemini
model at [ai.google.dev/docs](https://ai.google.dev/docs).
