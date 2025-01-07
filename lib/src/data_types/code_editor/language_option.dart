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
import 'package:highlight/highlight_core.dart';
export 'package:highlight/highlight_core.dart';

class LanguageItem {
  final Mode flutterCodeEditorType;
  final String markdownIdentifier;

  const LanguageItem({
    required this.flutterCodeEditorType,
    required this.markdownIdentifier,
  });
}

final Map<String, LanguageItem> languageMap = {
  'bash': LanguageItem(
    flutterCodeEditorType: shell,
    markdownIdentifier: 'bash',
  ),
  'cpp': LanguageItem(
    flutterCodeEditorType: cpp,
    markdownIdentifier: 'cpp',
  ),
  'csharp': LanguageItem(
    flutterCodeEditorType: cs,
    markdownIdentifier: 'csharp',
  ),
  'css': LanguageItem(
    flutterCodeEditorType: css,
    markdownIdentifier: 'css',
  ),
  'dart': LanguageItem(
    flutterCodeEditorType: dart,
    markdownIdentifier: 'dart',
  ),
  'go': LanguageItem(
    flutterCodeEditorType: go,
    markdownIdentifier: 'go',
  ),
  'html': LanguageItem(
    flutterCodeEditorType: xml,
    markdownIdentifier: 'html',
  ),
  'java': LanguageItem(
    flutterCodeEditorType: java,
    markdownIdentifier: 'java',
  ),
  'javascript': LanguageItem(
    flutterCodeEditorType: javascript,
    markdownIdentifier: 'javascript',
  ),
  'kotlin': LanguageItem(
    flutterCodeEditorType: kotlin,
    markdownIdentifier: 'kotlin',
  ),
  'markdown': LanguageItem(
    flutterCodeEditorType: markdown,
    markdownIdentifier: 'markdown',
  ),
  'objectivec': LanguageItem(
    flutterCodeEditorType: objectivec,
    markdownIdentifier: 'objective-c',
  ),
  'perl': LanguageItem(
    flutterCodeEditorType: perl,
    markdownIdentifier: 'perl',
  ),
  'php': LanguageItem(
    flutterCodeEditorType: php,
    markdownIdentifier: 'php',
  ),
  'python': LanguageItem(
    flutterCodeEditorType: python,
    markdownIdentifier: 'python',
  ),
  'r': LanguageItem(
    flutterCodeEditorType: r,
    markdownIdentifier: 'r',
  ),
  'ruby': LanguageItem(
    flutterCodeEditorType: ruby,
    markdownIdentifier: 'ruby',
  ),
  'rust': LanguageItem(
    flutterCodeEditorType: rust,
    markdownIdentifier: 'rust',
  ),
  'scala': LanguageItem(
    flutterCodeEditorType: scala,
    markdownIdentifier: 'scala',
  ),
  'sql': LanguageItem(
    flutterCodeEditorType: sql,
    markdownIdentifier: 'sql',
  ),
  'swift': LanguageItem(
    flutterCodeEditorType: swift,
    markdownIdentifier: 'swift',
  ),
  'plainText': LanguageItem(
    flutterCodeEditorType: cs,
    markdownIdentifier: 'plainText',
  ),
};
