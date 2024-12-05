import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/gruvbox-dark.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart'; // You can choose any theme
import '../../data_store.dart';
import '../../utils/syntax_highlighter_helper.dart';


class FlashCardEditor extends StatelessWidget {
  final int flashCardId;

  const FlashCardEditor({Key? key, required this.flashCardId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stream = Data()
        .store
        .box<FlashCard>()
        .query(FlashCard_.id.equals(flashCardId))
        .watch(triggerImmediately: true);

    return StreamBuilder<List<FlashCard>>(
      stream: stream.map((query) => query.find()),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit FlashCard')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit FlashCard')),
            body: const Center(child: Text('FlashCard not found')),
          );
        }

        final flashCard = snapshot.data!.first;
        final language = extractLanguage(flashCard.question);
        return Scaffold(
          appBar: AppBar(title: const Text('Edit FlashCard')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Input Field
                  TextFormField(
                    initialValue: flashCard.question,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      labelText:
                          'Input question here. Markdown and code blocks are supported.',
                    ),
                    onChanged: (value) {
                      flashCard.question = value;
                      Data().store.box<FlashCard>().put(flashCard);
                    },
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Question Preview:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  // Question Preview
                  MarkdownBody(
                    data: flashCard.question,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
                    syntaxHighlighter: CustomSyntaxHighlighter(theme: gruvboxDarkTheme, language: language),
                  ),
                  const Divider(height: 32.0),
                  // Answer Input Field
                  TextFormField(
                    initialValue: flashCard.answer,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      labelText:
                          'Input answer here. Markdown and code blocks are supported.',
                    ),
                    onChanged: (value) {
                      flashCard.answer = value;
                      Data().store.box<FlashCard>().put(flashCard);
                    },
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Answer Preview:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  // Answer Preview
                  MarkdownBody(
                    data: flashCard.answer,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
                    syntaxHighlighter: CustomSyntaxHighlighter(theme: gruvboxDarkTheme, language: language),
                  ),
                  const Divider(height: 32.0),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Data().store.box<FlashCard>().remove(flashCard.id);
                          Navigator.pop(context);
                        },
                        child: const Text('Delete FlashCard'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
