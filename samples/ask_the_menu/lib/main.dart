// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:web/web.dart' as html;
import 'package:http/http.dart' as http;
import 'dart:js_interop';

import 'widgets/api_key_widget.dart';
import 'widgets/message_widget.dart';
import 'widgets/text_field_decoration.dart';

final themeColor = ValueNotifier<Color>(Colors.orangeAccent);

void main() {
  runApp(const GenerativeAISample(title: 'Ask the Menu'));
}

class GenerativeAISample extends StatefulWidget {
  const GenerativeAISample({super.key, required this.title});
  final String title;

  @override
  State<GenerativeAISample> createState() => _GenerativeAISampleState();
}

class _GenerativeAISampleState extends State<GenerativeAISample> {
  String? apiKey;

  ThemeData theme(Brightness brightness) {
    final colors = ColorScheme.fromSeed(
      brightness: brightness,
      seedColor: themeColor.value,
    );
    return ThemeData(
      brightness: brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeColor,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: widget.title,
          theme: theme(Brightness.light),
          darkTheme: theme(Brightness.dark),
          themeMode: ThemeMode.system,
          home: switch (apiKey) {
            final providedKey? => Example(
                title: widget.title,
                apiKey: providedKey,
              ),
            _ => ApiKeyWidget(
                title: widget.title,
                onSubmitted: (key) {
                  setState(() => apiKey = key);
                },
              ),
          },
        );
      },
    );
  }
}

class Example extends StatefulWidget {
  const Example({
    super.key,
    required this.apiKey,
    required this.title,
  });

  final String apiKey, title;

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  final loading = ValueNotifier(false);
  final menu = ValueNotifier('');
  final messages = ValueNotifier<List<(Sender, String)>>([]);
  final controller = TextEditingController();
  late final ChatSession chat = chatModel.startChat();
  late final chatModel = GenerativeModel(
    model: 'gemini-pro',
    apiKey: widget.apiKey,
  );
  late final imageModel = GenerativeModel(
    model: 'gemini-pro-vision',
    apiKey: widget.apiKey,
  );

  Future<void> sendMessage() async {
    final message = controller.text.trim();
    if (message.isEmpty) return;
    controller.clear();
    addMessage(Sender.user, message);
    loading.value = true;
    try {
      String prompt = chatSessionPrompt;
      prompt = prompt.replaceAll('{{menu}}', menu.value);
      prompt = prompt.replaceAll('{{questions}}', message);
      final response = await chat.sendMessage(Content.text(prompt));
      if (response.text != null) {
        addMessage(Sender.system, response.text!);
      } else {
        addMessage(Sender.system, 'No Response');
      }
    } catch (e) {
      addMessage(Sender.system, 'Error sending message: $e');
    } finally {
      loading.value = false;
    }
  }

  void addMessage(Sender sender, String value, {bool clear = false}) {
    if (clear) messages.value = [];
    messages.value = messages.value.toList()..add((sender, value));
  }

  Future<String> extractMenu(String mimeType, Uint8List bytes) async {
    final theme = Theme.of(context);
    final response = await imageModel.generateContent([
      Content.multi([
        TextPart(extractDataFromMenuPrompt),
        DataPart(mimeType, bytes),
      ]),
    ]).then((res) => res.text ?? '');
    try {
      final color = await ColorScheme.fromImageProvider(
        provider: MemoryImage(bytes),
        brightness: theme.brightness,
      );
      themeColor.value = color.primary;
    } catch (e) {
      debugPrint('Error extracting image color: $e');
    }
    return response;
  }

  Future<void> loadMenu() async {
    final file = await pickFile();
    if (file == null) return;
    addMessage(Sender.system, 'Uploading menu...', clear: true);
    controller.clear();
    try {
      menu.value = await extractMenu('image/png', file);
      addMessage(Sender.system, menu.value, clear: true);
    } catch (e) {
      menu.value = '';
      addMessage(Sender.system, 'Error uploading menu: $e', clear: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: messages,
      builder: (context, child) {
        final reversed = messages.value.reversed;
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              IconButton(
                onPressed: loadMenu,
                icon: const Icon(Icons.image),
                tooltip: 'Upload a menu',
              )
            ],
          ),
          body: messages.value.isEmpty
              ? AnimatedBuilder(
                  animation: menu,
                  builder: (context, _) {
                    if (menu.value.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Upload a new menu'),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: loadMenu,
                              child: const Text('Select Image/PDF'),
                            ),
                          ],
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(8),
                      child: MarkdownBody(
                        data: menu.value,
                      ),
                    );
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  reverse: true,
                  itemCount: reversed.length,
                  itemBuilder: (context, index) {
                    final (sender, message) = reversed.elementAt(index);
                    return MessageWidget(
                      isFromUser: sender == Sender.user,
                      text: message,
                    );
                  },
                ),
          bottomNavigationBar: messages.value.isEmpty
              ? null
              : BottomAppBar(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: textFieldDecoration(context,
                              'Ask questions about price, food types, and suggestions on combos'),
                          onEditingComplete: sendMessage,
                          onSubmitted: (value) => sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedBuilder(
                        animation: loading,
                        builder: (context, _) {
                          if (loading.value) {
                            return const CircularProgressIndicator();
                          }
                          return IconButton(
                            onPressed: sendMessage,
                            icon: const Icon(Icons.send),
                            tooltip: 'Send a message',
                          );
                        },
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

const chatSessionPrompt = r'''
Given the following menu, respond with valid 
markdown the answers to the users questions:

```
{{menu}}
```

Questions about the menu:

```
{{questions}}
```
''';

const extractDataFromMenuPrompt = '''
Convert the restaurant menu to markdown and return all the items on the menu 
showing the title, description and price for each.

Should return pretty markdown that includes the section, item name, price and the full details of the item if available.
''';

enum Sender {
  user,
  system,
}

Future<Uint8List?> pickFile() async {
  final el = html.document.createElement('input') as html.HTMLInputElement;
  el.type = 'file';
  el.accept = 'image/*';
  el.click();
  final completer = Completer<Uri?>();
  el.onchange = (html.Event e) {
    final files = el.files;
    if (files != null && files.length != 0) {
      final file = files.item(0);
      if (file != null) {
        final reader = html.FileReader();
        reader.onload = (html.Event _) {
          final url = reader.result;
          if (url != null) {
            completer.complete(Uri.parse(url as String));
          } else {
            completer.complete(null);
          }
        }.toJS;
        reader.readAsDataURL(file);
      } else {
        completer.complete(null);
      }
    } else {
      completer.complete(null);
    }
  }.toJS;
  final result = await completer.future;
  el.remove();
  if (result != null) {
    final res = await http.get(result);
    if (res.statusCode == 200) {
      return res.bodyBytes;
    }
  }
  return null;
}
