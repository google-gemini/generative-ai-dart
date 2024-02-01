[![flutter_sample](https://github.com/google/generative-ai-dart/actions/workflows/flutter_sample.yml/badge.svg)](https://github.com/google/generative-ai-dart/actions/workflows/flutter_sample.yml)

# Flutter generative AI sample

A Flutter chat application that uses the `google_generative_ai` package.

## Getting started

To use the Gemini API, you'll need an API key. If you don't already have one, 
create a key in Google AI Studio: https://makersuite.google.com/app/apikey

Create the project files for each target platform by using the `flutter create`
command in this project's directory.

```bash
flutter create .
```

Create a new file, `env.json` to store your API key:

```json
{
  "api_key": "<YOUR_API_KEY_HERE>"
}
```

Specify the `env.json` file when you run the app:

```bash
flutter run -d android --dart-define-from-file=env.json
```
