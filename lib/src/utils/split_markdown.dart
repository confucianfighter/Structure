List<Map<String, dynamic>> splitMarkdown(String markdown) {
  final lines = markdown.split('\n');
  final blocks = <Map<String, dynamic>>[];
  final buffer = StringBuffer();
  bool inCodeBlock = false;
  String? currentLanguage;
  Map<String, dynamic> currentBlock;
  final codeBlockStartPattern = RegExp(r'^```(\w+)');
  final codeBlockEndPatter = RegExp(r'^```');
  void finalizeCurrentBlock(String type) {
    blocks.add({
      'type': type,
      'language': currentLanguage ?? 'plainEnglish',
      'content': buffer.toString().trim(),
    });
    buffer.clear();
    currentLanguage = null;
  }

  for (int i = 0; i < lines.length; i++) {
    // I start, I'm building a regular block.
    var line = lines[i];

    if (!inCodeBlock) {
      final match = codeBlockStartPattern.firstMatch(line);
      if (match != null) {
        // we are starting a new code block
        if (buffer.isNotEmpty) {
          finalizeCurrentBlock('markdown');
        }
        inCodeBlock = true;
        currentLanguage = match.group(1);
        continue;
      } else {
        // we are not starting a new code block
        buffer.writeln(line);
        continue;
      }
    } else {
      // we are in a code block
      final match = codeBlockEndPatter.firstMatch(line);
      if (match != null || i == lines.length - 1) {
        if (i == lines.length - 1 && match == null) {
          buffer.writeln(line);
        }
        inCodeBlock = false;

        if (buffer.isNotEmpty) {
          finalizeCurrentBlock('code');
        }
        currentLanguage = null;
        continue;
      } else {
        // Add the line to the current block
        buffer.writeln(line);
      }
    }
  }
  return blocks;
}
