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
import 'package:Structure/src/assets.dart';
import 'package:Structure/gen/assets.gen.dart' as ASSETS;
import 'package:Structure/src/data_store.dart';

class CodeEditorWidget extends StatefulWidget {
  final String initialText;
  final String language;
  final String languageSelectionTitle = 'Syntax Highlighting';
  final String languageSelectionHint = 'Select a language';
  final Function(String)? onLanguageChanged;
  final Function(String)? onChanged;
  final bool isFullScreen;

  const CodeEditorWidget({
    super.key,
    required this.initialText,
    required this.language,
    required this.onChanged,
    required this.onLanguageChanged,
    this.isFullScreen = true,
  });

  @override
  CodeEditorWidgetState createState() => CodeEditorWidgetState();
}

class CodeEditorWidgetState extends State<CodeEditorWidget> {
  late CodeController _codeController;
  late FocusNode _focusNode;
  late Mode _language;
  late String _languageStr;
  String? _cssPath = ASSETS.$AssetsCssBootstrapGen().bootstrapDarklyMin;
  String? _highlightJsCssPath = ASSETS.$AssetsCssHighlightGen().agate;
  String? _currentText;
  final List<String> _languages = languageMap.keys.toList();
  late List<String> _cssPaths = [];
  @override
  initState() {
    super.initState();
    assert(languageMap.containsKey(widget.language));
    _languageStr = widget.language;
    _language = languageMap[widget.language]?.flutterCodeEditorType ?? dart;
    _currentText = widget.initialText;
    _cssPaths = getCssThemeFilenames();
    _codeController = CodeController(
      text: widget.initialText,
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
      _codeController.language = _language;

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
    final editorContent = LayoutBuilder(
      builder: (context, constraints) {
        final isViewerEnabled =
            _languageStr == 'html' || _languageStr == 'markdown';

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
                : HTMLViewer(
                    //already editing.
                    language: widget.language,
                    showEditButton: false,
                    onLanguageChanged: null,
                    onChanged: null,
                    initialText: _currentText ?? "",
                    cssPath: _cssPath!,
                    highlightJsCssPath: _highlightJsCssPath!,
                  ))
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
                        var fileName = "${_languageStr.toLowerCase()}_guide.md";
                        // check if file exists in rootBundle
                        // if so set content to the file
                        // if not set content to a default message
                        var content =
                            'No quick reference available for $_languageStr';
                        if (await _checkGuideExists(_languageStr)) {
                          content =
                              await rootBundle.loadString('assets/$fileName');
                        }

                        // Open a dialog with the quick reference for the selected language
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MdViewerPage(
                              content: content,
                              title: '$_languageStr Quick Reference',
                            ),
                          ),
                        );
                      },
                      child: Text('$_languageStr Quick Reference'),
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
                              Row(children: [
                                Expanded(
                                    flex: 1,
                                    child: SearchableDropdown(
                                      // dropdown for selecting css theme
                                      items: _cssPaths,
                                      initialValue:
                                          Settings.get()?.cssStylePath,
                                      onChanged: (css) {
                                        // set the theme to the selected css file
                                        setState(() {
                                          Settings? settings = Settings.get();
                                          settings?.cssStylePath = css;
                                          if (settings != null) {
                                            Data()
                                                .store
                                                .box<Settings>()
                                                .put(settings);
                                          }
                                          _cssPath = css;
                                        });
                                      },
                                      labelText: 'Select a CSS theme',
                                      hintText: 'Select a CSS theme',
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: SearchableDropdown(
                                      // dropdown for selecting css theme
                                      items: Assets()
                                          .getFilePaths('css/highlight'),
                                      initialValue:
                                          Settings.get()?.codeStylePath,
                                      onChanged: (css) {
                                        // set the theme to the selected css file
                                        setState(() {
                                          _highlightJsCssPath = css;
                                          Settings? settings = Settings.get();
                                          if (settings != null) {
                                            settings.codeStylePath = css;
                                            Settings.set(settings);
                                          }
                                        });
                                      },
                                      labelText:
                                          'Select a syntax highlighting theme',
                                      hintText:
                                          'Select a syntax highlighting theme',
                                    ))
                              ]),
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

    return widget.isFullScreen
        ? Scaffold(
            appBar: AppBar(
              title: Text('Code Editor'),
            ),
            body: editorContent,
          )
        : editorContent;
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

List<String> getCssThemeFilenames() {
  // Hardcoded list of filenames (based on pubspec.yaml entries)
  return Assets().getFilePaths('css/bootstrap');
}
