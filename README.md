# Google Generative AI SDK for Dart

The Google AI Dart SDK is the easiest way for Dart developers to build with the Gemini API. The Gemini API gives you access to Gemini [models](https://ai.google.dev/models/gemini) created by [Google DeepMind](https://deepmind.google/technologies/gemini/#introduction). Gemini models are built from the ground up to be multimodal, so you can reason seamlessly across text, images, and code.

> [!CAUTION]
> **Using the Google AI SDK for Dart (Flutter) to call the Google AI Gemini API
> directly from your app is recommended for prototyping only.** If you plan to
> enable billing, we strongly recommend that you use the SDK to call the Google
> AI Gemini API only server-side to keep your API key safe. You risk potentially
> exposing your API key to malicious actors if you embed your API key directly
> in your mobile or web app or fetch it remotely at runtime.

## Get started with the Gemini API

## Getting Started

1. Go to [Google AI Studio](https://aistudio.google.com/).
2. Login with your Google account.
3. [Create](https://aistudio.google.com/app/apikey) an API key. Note that in Europe the free tier is not available.
4. Try a Dart SDK [example](samples/dart) or the [Flutter ample app](samples/flutter_app/).
5. For detailed instructions, try the
[Dart SDK tutorial](https://ai.google.dev/gemini-api/docs/get-started/tutorial?lang=dart) on [ai.google.dev](https://ai.google.dev).

## Usage example

See the [Gemini API Cookbook](https://ai.google.dev/gemini-api/docs/get-started/tutorial?lang=dart) or [ai.google.dev](https://ai.google.dev) for complete code.

Add a dependency on the `package:google_generative_ai` package via:

```shell
dart pub add google_generative_ai
```

or:

```shell
flutter pub add google_generative_ai
```

Initialize the API client

```dart
final model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);
```

Call the API

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

See the [Gemini API Cookbook](https://github.com/google-gemini/gemini-api-cookbook/) or [ai.google.dev](https://ai.google.dev) for complete documentation.

## Contributing

See [Contributing](CONTRIBUTING.md) for more information on contributing to the
Generative AI SDK for Dart.

## License

The contents of this repository are licensed under the
[Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
