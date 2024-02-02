[![flutter_sample](https://github.com/google/generative-ai-dart/actions/workflows/flutter_sample.yml/badge.svg)](https://github.com/google/generative-ai-dart/actions/workflows/flutter_sample.yml)

# Flutter generative AI sample

A Flutter chat application that uses the `google_generative_ai` package.

## Getting started

To use the Gemini API, you'll need an API key. If you don't already have one, 
create a key in Google AI Studio: https://makersuite.google.com/app/apikey.

Create the project files for each target platform by using the `flutter create`
command in this project's directory.

```bash
flutter create .
```

When running the app, include your API key using the `--dart-define` flag:

```bash
flutter run --dart-define=API_KEY=$GOOGLE_API_KEY
```

If you use VSCode, you can [specify `--dart-define`
variables](https://dartcode.org/docs/using-dart-define-in-flutter/) in your
launch.json file.
