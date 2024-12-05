import 'package:flutter_highlight/themes/github.dart';

final RegExp codeBlockPattern = RegExp(r'```(\w+)?\n([\s\S]*?)```');

/// Splits Markdown content into regular text and code blocks.
List<Map<String, dynamic>> splitMarkdown(String markdown) {
  final matches = codeBlockPattern.allMatches(markdown);
  final blocks = <Map<String, dynamic>>[];

  int currentIndex = 0;

  for (final match in matches) {
    // Add regular text block before the code block
    if (match.start > currentIndex) {
      blocks.add({
        'type': 'markdown',
        'content': markdown.substring(currentIndex, match.start).trim(),
      });
    }

    // Add code block
    blocks.add({
      'type': 'code',
      'language': match.group(1) ?? 'plaintext',
      'content': match.group(2)?.trim() ?? '',
    });

    currentIndex = match.end;
  }

  // Add remaining regular text after the last code block
  if (currentIndex < markdown.length) {
    blocks.add({
      'type': 'markdown',
      'content': markdown.substring(currentIndex).trim(),
    });
  }

  return blocks;
}
