import 'md_viewer.dart';
import 'package:flutter/material.dart';

class MdViewerPage extends StatelessWidget {
  final String content;
  final String title;

  const MdViewerPage({
    Key? key,
    required this.content,
    required this.title,
    // Default to Gruvbox Dark
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: MdViewer(content: content),
        ),
      ),
    );
  }
}
