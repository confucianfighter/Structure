import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/dart.dart'; // Default language
import '../html_viewer/html_viewer.dart'; // Import webview_flutter
import '../nuts_and_bolts/searchable_dropdown.dart'; // Custom dropdown implementation
import '../../data_types/code_editor/language_option.dart';
import '../md/md_viewer.dart';

class CodeEditorWidget extends StatefulWidget {
  final String initialCode;
  final String language;
  final String languageSelectionTitle;
  final String languageSelectionHint;
  final Function(String)? onLanguageChanged;
  final Function(String)? onChanged;

  const CodeEditorWidget({
    Key? key,
    this.initialCode = '',
    this.language = 'rust',
    required this.onChanged,
    required this.onLanguageChanged,
    required this.languageSelectionTitle,
    required this.languageSelectionHint,
  }) : super(key: key);

  @override
  CodeEditorWidgetState createState() => CodeEditorWidgetState();
}

class CodeEditorWidgetState extends State<CodeEditorWidget> {
  late CodeController _codeController;
  late FocusNode _focusNode;
  late Mode _language;
  String? _currentText;
  List<String> _languages = languageMap.keys.toList();

  @override
  void initState() {
    super.initState();
    assert(languageMap.containsKey(widget.language));
    _language = languageMap[widget.language]?.flutterCodeEditorType ?? dart;
    _currentText = widget.initialCode;
    _codeController = CodeController(
      text: widget.initialCode,
      language: _language,
    );

    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onLanguageSelected(String newLanguage) {
    setState(() {
      _language = languageMap[newLanguage]?.flutterCodeEditorType ?? dart;
      widget.onLanguageChanged?.call(newLanguage);
    });
  }

  void _onTextChanged(String newText) {
    setState(() {
      _currentText = newText;
      widget.onChanged?.call(newText);
    });
  }

  Widget _buildEditorAndViewer(String language) {
    final codeField = CodeTheme(
      data: CodeThemeData(styles: monokaiSublimeTheme),
      child: CodeField(
        controller: _codeController,
        focusNode: _focusNode,
        gutterStyle: GutterStyle.none,
        textStyle: const TextStyle(fontSize: 14.0, fontFamily: 'monospace'),
        onChanged: (text) => _onTextChanged(text),
      ),
    );

    if (language == 'markdown' || language == 'html') {
      // The viewer may need scrolling if content is large.
      // Instead of Expanded, we rely on natural sizing.
      // If we do need scrolling, let's wrap the viewer in a SingleChildScrollView.
      final viewer = (language == 'markdown')
          ? MdViewer(content: _codeController.text)
          : SizedBox(
              height:
                  300, // Provide some bounding height to avoid infinite growth
              child: HTMLViewer(
                key: ValueKey(_currentText),
                htmlContent: _currentText ?? '',
              ),
            );

      final guideButton = ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            language == 'markdown' ? '/md-guide' : '/html-guide',
          );
        },
        child: Text(language == 'markdown' ? 'Markdown Guide' : 'HTML Guide'),
      );

      // Notice: No Expanded here. Just a natural layout.
      // If needed, you could wrap this entire Row in another scrollable or a sized container.
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Flexible on a Row affects width, which is safe since we have bounded width from LayoutBuilder
          Flexible(
            fit: FlexFit.loose,
            child: codeField,
          ),
          const SizedBox(width: 16),
          // Another Flexible for width distribution
          Flexible(
            fit: FlexFit.loose,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                guideButton,
                // No Expanded here. If viewer content might overflow, make the viewer scrollable or give it a fixed height.
                viewer,
              ],
            ),
          ),
        ],
      );
    } else {
      // For other languages, just return the code field without expansions.
      return codeField;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Add runtime checks for debugging:
        if (constraints.maxHeight == double.infinity) {
          debugPrint(
            'Warning: Unbounded height detected. Consider wrapping CodeEditorWidget '
            'in a widget that provides a bounded height.',
          );
        }

        return Column(
          // mainAxisSize.min tries to shrink-wrap the contents
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchableDropdown(
              items: _languages,
              initialValue: widget.language,
              onChanged: (text) => _onLanguageSelected(text),
              labelText: widget.languageSelectionTitle,
              hintText: widget.languageSelectionHint,
            ),
            const SizedBox(height: 12.0),
            // No Expanded or Flexible here since we might be in an unbounded height scenario.
            // Just rely on natural sizing.
            _buildEditorAndViewer(widget.language),
          ],
        );
      },
    );
  }
}
