import 'package:flutter/material.dart';
import 'templates.dart';

class TemplateUI extends StatefulWidget {
  @override
  _TemplateUIState createState() => _TemplateUIState();
}

class _TemplateUIState extends State<TemplateUI> {
  String? selectedTemplate;
  final Map<String, Widget Function()> templates = {
    'Login Page': Templates.loginPage,
    'Dashboard': Templates.dashboard,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Template Selector'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: templates.keys.length,
              itemBuilder: (context, index) {
                String templateName = templates.keys.elementAt(index);
                return ListTile(
                  title: Text(templateName),
                  trailing: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedTemplate = templateName;
                      });
                      _customizeTemplate(templateName);
                    },
                    child: Text('Customize'),
                  ),
                  onTap: () {
                    setState(() {
                      selectedTemplate = templateName;
                    });
                  },
                );
              },
            ),
          ),
          if (selectedTemplate != null)
            Expanded(
              child: Column(
                children: [
                  Text('Preview: $selectedTemplate'),
                  Expanded(
                    child: templates[selectedTemplate!]!(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _customizeTemplate(String templateName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Customize $templateName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Text'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Color'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Structure'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _saveTemplateChanges();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveTemplateChanges() {
    // Implement the logic to save changes made to the template
  }
}
