[![flutter_sample](https://github.com/google/generative-ai-dart/actions/workflows/flutter_sample.yml/badge.svg)](https://github.com/google/generative-ai-dart/actions/workflows/flutter_sample.yml)

# Flutter generative AI sample

A Flutter chat application that uses the `google_generative_ai` package.

## Getting started

To use the Gemini API, you'll need an API key. If you don't already have one, 
create a key in Google AI Studio: https://aistudio.google.com/app/apikey.

When running the app, include your API key using the `--dart-define` flag:

```bash
flutter run --dart-define=API_KEY=$GEMINI_API_KEY
```

If you use VSCode, you can [specify `--dart-define`
variables](https://dartcode.org/docs/using-dart-define-in-flutter/) in your
launch.json file.

If you use Android Studio or IntelliJ you can use run / debug configurations
(https://www.jetbrains.com/help/idea/run-debug-configuration.html).

## Using the GenerativeModel for Code Generation

The `GenerativeModel` class from the `google_generative_ai` package can be used to generate boilerplate code, widgets, and repetitive structures efficiently. Below are the steps to integrate and use the `GenerativeModel` for code generation in your Flutter project.

### Step 1: Import the `GenerativeModel` Class

First, import the `GenerativeModel` class in your Dart file:

```dart
import 'package:google_generative_ai/google_generative_ai.dart';
```

### Step 2: Initialize the `GenerativeModel`

Create an instance of the `GenerativeModel` class by providing your API key and the model name:

```dart
final model = GenerativeModel(
  model: 'gemini-1.5-flash-latest',
  apiKey: 'YOUR_API_KEY',
);
```

### Step 3: Generate Boilerplate Code

Use the `generateContent` method to generate boilerplate code. For example, to generate a Flutter widget:

```dart
Future<void> generateFlutterWidget() async {
  final prompt = 'Generate a Flutter widget for a login form.';
  final content = [Content.text(prompt)];
  final response = await model.generateContent(content);

  print(response.text);
}
```

### Step 4: Display the Generated Code

You can display the generated code in your Flutter app. For example, you can use a `Text` widget to display the generated code:

```dart
class GeneratedCodeWidget extends StatelessWidget {
  final String generatedCode;

  const GeneratedCodeWidget({required this.generatedCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generated Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(generatedCode),
        ),
      ),
    );
  }
}
```

### Step 5: Integrate with Your App

Integrate the code generation functionality with your app. For example, you can add a button to trigger the code generation and display the generated code:

```dart
class CodeGenerationScreen extends StatefulWidget {
  @override
  _CodeGenerationScreenState createState() => _CodeGenerationScreenState();
}

class _CodeGenerationScreenState extends State<CodeGenerationScreen> {
  String? generatedCode;

  Future<void> generateCode() async {
    final prompt = 'Generate a Flutter widget for a login form.';
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    setState(() {
      generatedCode = response.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Code Generation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (generatedCode != null)
              GeneratedCodeWidget(generatedCode: generatedCode!),
            ElevatedButton(
              onPressed: generateCode,
              child: Text('Generate Code'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Troubleshooting

If you encounter any issues while setting up or using the `GenerativeModel` for code generation, refer to the following troubleshooting tips:

- Ensure that you have provided a valid API key.
- Check your internet connection.
- Verify that the `google_generative_ai` package is added to your `pubspec.yaml` file.
- Ensure that you are using the correct model name.

For more detailed instructions and examples, refer to the [google_generative_ai package documentation](https://pub.dev/packages/google_generative_ai).
