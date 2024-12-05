import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:highlight/highlight.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class CustomSyntaxHighlighter implements SyntaxHighlighter {
  final Map<String, TextStyle> theme;
  CustomSyntaxHighlighter({required this.theme, required this.language});
  final String language;
  @override
  TextSpan format(String source) {
    // Use HighlightView to highlight the code

    return TextSpan(
      style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
      children: [
        WidgetSpan(
          child: HighlightView(
            source, // The source code to highlight
            language: language,
            // Automatically detect the language
            theme: theme, // Use the specified theme
            padding: EdgeInsets.all(8),
            textStyle: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}

final RegExp codeFencePattern = RegExp(r'^```(\w+)?\s*$');

String matchCodeFence(String line) {
  final match = codeFencePattern.firstMatch(line);
  return match?.group(1) ??
      'plaintext'; // Default to 'plaintext' if no language is specified
}

String extractLanguage(String markdown) {
  final lines = markdown.split('\n');
  for (var line in lines) {
    if (codeFencePattern.hasMatch(line)) {
      return matchCodeFence(line);
      // Handle the code block with the specified language
    }
    // Process other lines
  }
  return 'plaintext'; // Default to 'plaintext' if no language is specified
}
