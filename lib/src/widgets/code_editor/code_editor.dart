import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/dart.dart'; // you can adjust this based on selected language
import '../nuts_and_bolts/searchable_dropdown.dart'; // Assuming you have this implemented from previous code.
import '../../data_types/code_editor/language_option.dart';

class CodeEditorWidget extends StatefulWidget {
  // You can pass in initial code or initial language if needed
  final String initialCode;
  final String language;
  final Function(String)? onLanguageChanged; // callback if needed

  const CodeEditorWidget({
    Key? key,
    this.initialCode = '',
    this.language = 'dart',
    this.onLanguageChanged,
  }) : super(key: key);

  @override
  CodeEditorWidgetState createState() => CodeEditorWidgetState();
}

class CodeEditorWidgetState extends State<CodeEditorWidget> {
  late CodeController _codeController;
  late FocusNode _focusNode;
  late Mode? _language; // Default language
  List<String> _languages = languageMap.keys.toList();
  @override
  void initState() {
    super.initState();
    // assert that language is in the map
    assert(languageMap.containsKey(widget.language));
    _language = languageMap[widget.language]?.flutterCodeEditorType ?? dart;
    _codeController = CodeController(
      text: widget.initialCode,
      language: _language ?? dart,
    );
    _focusNode = FocusNode();

    // Request focus after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String getCode() {
    return _codeController.text;
  }

  void _onLanguageSelected(String newLanguage) {
    setState(() {
      _language = languageMap[widget.language]?.flutterCodeEditorType;
      // If you have logic to switch syntax highlighting based on language:
      // _codeController.language = selectedLanguageMapping[newLanguage];
    });
    if (widget.onLanguageChanged != null) {
      widget.onLanguageChanged!(newLanguage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Searchable Dropdown at the top
        // Assuming you have a `LanguageSelector` similar to what we previously discussed
        // which returns onLanguageSelected callback.
        // You can replace this with your searchable dropdown widget directly.
        SearchableDropdown(
          items: _languages,
          initialValue: widget.language,
          onChanged: _onLanguageSelected,
          labelText: 'Language',
          hintText: 'syntax highlighting',
        ),

        const SizedBox(height: 12.0),

        Expanded(
          child: CodeTheme(
            data: CodeThemeData(styles: monokaiSublimeTheme),
            child: CodeField(
              controller: _codeController,
              focusNode: _focusNode,
              gutterStyle: GutterStyle.none,
              textStyle:
                  const TextStyle(fontSize: 14.0, fontFamily: 'monospace'),
            ),
          ),
        ),
      ],
    );
  }
}
