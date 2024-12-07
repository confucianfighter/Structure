import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/gruvbox-dark.dart';
import 'package:flutter_highlight/themes/vs.dart';
import 'package:flutter_highlight/themes/atelier-dune-dark.dart';
import '../../utils/split_markdown.dart';

class MdViewer extends StatelessWidget {
  final String content;
  final Map<String, TextStyle> theme;

  const MdViewer({
    Key? key,
    required this.content,
    this.theme = atelierDuneDarkTheme, // Default to Gruvbox Dark
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final blocks = splitMarkdown(content);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) {
        if (block['type'] == 'markdown') {
          return MarkdownBody(
            data: block['content']!,
            selectable: true,
            styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
          );
        } else if (block['type'] == 'code') {
          return HighlightView(
            block['content']!,
            language: block['language']!,
            theme: theme,
            padding: const EdgeInsets.all(8),
            textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 14),
          );
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }
}
