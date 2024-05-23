# Google Generative AI SDK for Dart

The Google Generative AI SDK for Dart allows developers to use state-of-the-art
Large Language Models (LLMs) to build language applications.

See the [API overview of Gemini][Gemini API] for more information about
generative models features and behaviors.

> [!CAUTION]
> **Using the Google AI SDK for Dart (Flutter) to call the Google AI Gemini API
> directly from your app is recommended for prototyping only.** If you plan to
> enable billing, we strongly recommend that you use the SDK to call the Google
> AI Gemini API only server-side to keep your API key safe. You risk potentially
> exposing your API key to malicious actors if you embed your API key directly
> in your mobile or web app or fetch it remotely at runtime.

[Gemini API]: https://ai.google.dev/gemini-api/docs/api-overview#dart-flutter

## Getting Started

### API keys

To use the Gemini API, you'll need an API key. If you don't already have one, 
create a key in Google AI Studio: https://aistudio.google.com/app/apikey.

### Dart samples

See the Dart sample apps at [samples/dart](samples/dart/),
including some getting started instructions.

### Flutter sample

See a Flutter sample app at [samples/flutter_app](samples/flutter_app/),
including some getting started instructions.

## Using the SDK in your own app

Add a dependency on the `package:google_generative_ai` package via:

```shell
dart pub add google_generative_ai
```

or:

```shell
flutter pub add google_generative_ai
```

### Initializing the API client

```dart
final model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);
```

### Calling the API

```dart
final prompt = 'Do these look store-bought or homemade?';
final imageBytes = await File('cookie.png').readAsBytes();
final content = [
  Content.multi([
    TextPart(prompt),
    DataPart('image/png', imageBytes),
  ])
];

final response = await model.generateContent(content);
print(response.text);

```

## Documentation

Find complete documentation for the Google AI SDKs and the Gemini model in the
Google documentation: https://ai.google.dev/docs.

## Packages

| Package                                            | Description | Version |
| -------------------------------------------------- | --- | --- |
| [google_generative_ai](pkgs/google_generative_ai/) | The Google Generative AI SDK for Dart - allows access to state-of-the-art LLMs. | [![pub package](https://img.shields.io/pub/v/google_generative_ai.svg)](https://pub.dev/packages/google_generative_ai) |
| [samples/dart](samples/dart/)                      | Dart samples for `package:google_generative_ai`. |  |
| [samples/flutter_app](samples/flutter_app/)        | A Flutter sample for `package:google_generative_ai`. |  |

## Contributing

See [Contributing](CONTRIBUTING.md) for more information on contributing to the
Generative AI SDK for Dart.

## License

The contents of this repository are licensed under the
[Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
