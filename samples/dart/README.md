[![samples](https://github.com/google/generative-ai-dart/actions/workflows/samples.yml/badge.svg)](https://github.com/google/generative-ai-dart/actions/workflows/samples.yml)

## Getting started

To try these samples out, follow these steps:

- To use the Gemini API, you'll need an API key. If you don't already have one, 
  create a key in Google AI Studio: https://aistudio.google.com/app/apikey.
- Export a `$GEMINI_API_KEY` environment variable with an API key with access to
  the Gemini generative models, or run the below commands with an environment
  containing this variable.
- Run any sample from the `bin` directory (e.g., `dart bin/simple_text.dart`).

## Contents

| File                                                           | Description |
|----------------------------------------------------------------| ----------- |
| [chat.dart](bin/chat.dart)                                     | Multi-turn chat conversations |
| [code_execution.dart](bin/code_execution.dart)                 | Executing code |
| [controlled_generation.dart](bin/controlled_generation.dart)   | Generating content with output constraints (e.g. JSON mode) |
| [count_tokens.dart](bin/count_tokens.dart)                     | Counting input and output tokens |
| [function_calling.dart](bin/function_calling.dart)             | Using function calling |
| [safety_settings.dart](bin/safety_settings.dart)               | Setting and using safety controls |
| [system_instruction.dart](bin/system_instruction.dart)         | Setting system instructions |
| [text_generation.dart](bin/text_generation.dart)               | Generating text |
