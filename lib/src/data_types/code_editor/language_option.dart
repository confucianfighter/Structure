// language_options.dart

import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/cs.dart';
import 'package:highlight/languages/php.dart';
import 'package:highlight/languages/swift.dart';
import 'package:highlight/languages/kotlin.dart';
import 'package:highlight/languages/ruby.dart';
import 'package:highlight/languages/go.dart';
import 'package:highlight/languages/rust.dart';
import 'package:highlight/languages/objectivec.dart';
import 'package:highlight/languages/shell.dart';
import 'package:highlight/languages/xml.dart';
import 'package:highlight/languages/css.dart';
import 'package:highlight/languages/sql.dart';
import 'package:highlight/languages/r.dart';
import 'package:highlight/languages/perl.dart';
import 'package:highlight/languages/scala.dart';
import 'package:highlight/languages/markdown.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/highlight_core.dart';

class LanguageItem {
  final Mode flutterCodeEditorType;
  final String markdownIdentifier;

  const LanguageItem({
    required this.flutterCodeEditorType,
    required this.markdownIdentifier,
  });
}

final Map<String, LanguageItem> languageMap = {
  'dart': LanguageItem(
    flutterCodeEditorType: dart,
    markdownIdentifier: 'dart',
  ),
  'javascript': LanguageItem(
    flutterCodeEditorType: javascript,
    markdownIdentifier: 'javascript',
  ),
  'python': LanguageItem(
    flutterCodeEditorType: python,
    markdownIdentifier: 'python',
  ),
  'java': LanguageItem(
    flutterCodeEditorType: java,
    markdownIdentifier: 'java',
  ),
  'cpp': LanguageItem(
    flutterCodeEditorType: cpp,
    markdownIdentifier: 'cpp',
  ),
  'csharp': LanguageItem(
    flutterCodeEditorType: cs,
    markdownIdentifier: 'csharp',
  ),
  'php': LanguageItem(
    flutterCodeEditorType: php,
    markdownIdentifier: 'php',
  ),
  'swift': LanguageItem(
    flutterCodeEditorType: swift,
    markdownIdentifier: 'swift',
  ),
  'kotlin': LanguageItem(
    flutterCodeEditorType: kotlin,
    markdownIdentifier: 'kotlin',
  ),
  'ruby': LanguageItem(
    flutterCodeEditorType: ruby,
    markdownIdentifier: 'ruby',
  ),
  'go': LanguageItem(
    flutterCodeEditorType: go,
    markdownIdentifier: 'go',
  ),
  'rust': LanguageItem(
    flutterCodeEditorType: rust,
    markdownIdentifier: 'rust',
  ),
  'objectivec': LanguageItem(
    flutterCodeEditorType: objectivec,
    markdownIdentifier: 'objective-c',
  ),
  'shell': LanguageItem(
    flutterCodeEditorType: shell,
    markdownIdentifier: 'bash',
  ),
  'markup': LanguageItem(
    flutterCodeEditorType: xml,
    markdownIdentifier: 'markup',
  ),
  'css': LanguageItem(
    flutterCodeEditorType: css,
    markdownIdentifier: 'css',
  ),
  'sql': LanguageItem(
    flutterCodeEditorType: sql,
    markdownIdentifier: 'sql',
  ),
  'r': LanguageItem(
    flutterCodeEditorType: r,
    markdownIdentifier: 'r',
  ),
  'perl': LanguageItem(
    flutterCodeEditorType: perl,
    markdownIdentifier: 'perl',
  ),
  'scala': LanguageItem(
    flutterCodeEditorType: scala,
    markdownIdentifier: 'scala',
  ),
  'markdown': LanguageItem(
    flutterCodeEditorType: markdown,
    markdownIdentifier: 'markdown',
  ),
};
