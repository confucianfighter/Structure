import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/dart.dart';
import '../html_viewer/html_viewer.dart';
import '../nuts_and_bolts/searchable_dropdown.dart';
import '../../data_types/code_editor/language_option.dart';
import '../md/md_viewer.dart';
import '../md/md_viewer_page.dart';

class CodeEditorWidget extends StatefulWidget {
  final String initialCode;
  final String language;
  final String languageSelectionTitle;
  final String languageSelectionHint;
  final Function(String)? onLanguageChanged;
  final Function(String)? onChanged;

  const CodeEditorWidget({
    Key? key,
    required this.initialCode,
    required this.language,
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
  late String _languageStr;
  String? _theme = 'assets/css/bootstrap_darkly.min.css';
  String? _currentText;
  List<String> _languages = languageMap.keys.toList();
  late List<String> _cssPaths = [];
  @override
  initState() {
    super.initState();
    assert(languageMap.containsKey(widget.language));
    _languageStr = widget.language;
    _language = languageMap[widget.language]?.flutterCodeEditorType ?? dart;
    _currentText = widget.initialCode;
    _cssPaths = getCssFilenames();
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
      _languageStr = newLanguage;
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isViewerEnabled =
            widget.language == 'html' || widget.language == 'markdown';

        final editor = SingleChildScrollView(
            child: CodeTheme(
          data: CodeThemeData(styles: monokaiSublimeTheme),
          child: CodeField(
            controller: _codeController,
            focusNode: _focusNode,
            gutterStyle: GutterStyle.none,
            textStyle: const TextStyle(fontSize: 14.0, fontFamily: 'monospace'),
            onChanged: _onTextChanged,
          ),
        ));

        final viewer = isViewerEnabled
            ? (widget.language == 'markdown'
                ? SingleChildScrollView(
                    child: MdViewer(content: _codeController.text))
                : HTMLViewer(htmlContent: _codeController.text, style: _theme!))
            : null;

        return Column(
          children: [
            // row containing language selection dropdown followed by a button that says "${_langauge} Quick Reference"
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: SearchableDropdown(
                      items: _languages,
                      initialValue: widget.language,
                      onChanged: (language) => _onLanguageSelected(language),
                      labelText: widget.languageSelectionTitle,
                      hintText: widget.languageSelectionHint,
                    )),
                // add space between dropdown and button
                const SizedBox(width: 8.0),
                Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () async {
                        var file_name =
                            "${_languageStr.toLowerCase()}_guide.md";
                        // check if file exists in rootBundle
                        // if so set content to the file
                        // if not set content to a default message
                        var content =
                            'No quick reference available for ${_languageStr}';
                        if (await _checkGuideExists(_languageStr)) {
                          content =
                              await rootBundle.loadString('assets/$file_name');
                        }

                        // Open a dialog with the quick reference for the selected language
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MdViewerPage(
                              content: content,
                              title: '${_languageStr} Quick Reference',
                            ),
                          ),
                        );
                      },
                      child: Text('${_languageStr} Quick Reference'),
                    ))
              ],
            ),
            const SizedBox(height: 12.0),
            Expanded(
              child: isViewerEnabled
                  ? Row(
                      children: [
                        Flexible(
                          flex: 1, // Half width for editor
                          child: Column(
                            children: [
                              Expanded(child: editor),
                            ],
                          ),
                        ),
                        const SizedBox(
                            width: 8), // Spacer between editor and viewer
                        Flexible(
                          flex: 1, // Half width for viewer
                          child: Column(
                            children: [
                              SearchableDropdown(
                                // dropdown for selecting css theme
                                items: _cssPaths,
                                initialValue: _theme,
                                onChanged: (css) {
                                  // set the theme to the selected css file
                                  setState(() {
                                    _theme = css;
                                  });
                                },
                                labelText: 'Select a CSS theme',
                                hintText: 'Select a CSS theme',
                              ),
                              Expanded(child: viewer!),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(child: editor), // Full width for editor
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

Future<bool> _checkGuideExists(String language) async {
  final assetPath = 'assets/${language}_guide.md';
  try {
    // Attempt to load the asset
    await rootBundle.loadString(assetPath);
    return true;
  } catch (e) {
    // If an exception occurs, the asset does not exist
    return false;
  }
}

List<String> getCssFilenames() {
  // Hardcoded list of filenames (based on pubspec.yaml entries)
  return [
    'assets/css/bootstrap_sketchy.min.css',
    'assets/css/bootstrap_darkly.min.css',
    'assets/css/bootstrap_flatly.min.css',
    'assets/css/bootstrap_litera.min.css',
    'assets/css/bootstrap_neomorph.min.css',
    'assets/css/bootstrap_slate.min.css',
  ];
}
