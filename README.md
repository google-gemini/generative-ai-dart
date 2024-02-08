# Google Generative AI SDK for Dart

The Google Generative AI SDK for Dart allows developers to use state-of-the-art
Large Language Models (LLMs) to build language applications.

## Getting Started

### API keys

To use the Gemini API, you'll need an API key. If you don't already have one, 
create a key in Google AI Studio: https://makersuite.google.com/app/apikey.

### Dart samples

See the Dart sample apps at [samples/dart](samples/dart/),
including some getting started instructions.

### Flutter sample

See a Flutter sample app at [samples/flutter_app](samples/flutter_app/),
including some getting started instructions.

## Using the SDK in your own app

Add a dependency on this repository to the path `pkgs/google_generative_ai`.
Once the API is stable the package will be available from pub. We welcome
pre-publish feedback through GitHub issues.

```yaml
dependencies:
  google_generative_ai:
    git:
      url: git@github.com:google/generative-ai-dart.git
      path: pkgs/google_generative_ai
      ref: main
```

### Initializing the API client

```dart
final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
```

### Calling the API

```dart
final prompt = 'Write a story about a magic backpack.';
final content = [Content.text(prompt)];
final response = await model.generateContent(content);
print(response.text);
```

## Documentation

Find complete documentation for the Google AI SDKs and the Gemini model in the
Google documentation: https://ai.google.dev/docs.

## Packages

| Package                                            | Description | Version |
| -------------------------------------------------- | --- | --- |
| [google_generative_ai](pkgs/google_generative_ai/) | The Google Generative AI SDK for Dart - allows access to state-of-the-art LLMs. |  |
| [samples/dart](samples/dart/)                      | Dart samples for `package:google_generative_ai`. |  |
| [samples/flutter_app](samples/flutter_app/)        | Flutter sample for `package:google_generative_ai`. |  |

## Contributing

See [Contributing](CONTRIBUTING.md) for more information on contributing to the
Generative AI SDK for Dart.

## License

The contents of this repository are licensed under the
[Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
