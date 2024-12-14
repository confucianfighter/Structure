import 'package:flutter/material.dart';
import '../../data_store.dart';
import '../md/md_editor.dart';
import 'flash_card.dart';
import '../nuts_and_bolts/searchable_dropdown.dart';
import '../../data_types/code_editor/language_option.dart';
import '../code_editor/code_editor.dart';
import '../html_viewer/html_viewer.dart';
import 'package:Structure/gen/assets.gen.dart';

class FlashCardEditor extends StatefulWidget {
  final int flashCardId;

  const FlashCardEditor({super.key, required this.flashCardId});

  @override
  _FlashCardEditorState createState() => _FlashCardEditorState();
}

class _FlashCardEditorState extends State<FlashCardEditor> {
  late final Stream<List<FlashCard>> _flashCardStream;

  @override
  void initState() {
    super.initState();
    // Create the stream once in initState
    _flashCardStream = Data()
        .store
        .box<FlashCard>()
        .query(FlashCard_.id.equals(widget.flashCardId))
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FlashCard>>(
      stream: _flashCardStream, // Use the pre-created stream
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

        return Scaffold(
          appBar: AppBar(title: const Text('Edit FlashCard'), actions: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlashCardWidget(
                      flashCard: flashCard,
                      testMode: true,
                      onAnswerSubmitted: (isCorrect) {
                        Data().store.box<FlashCard>().put(flashCard);
                      },
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                flashCard.timesCorrect = 0;
                flashCard.timesIncorrect = 0;
                Data().store.box<FlashCard>().put(flashCard);
              },
            ),
          ]),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
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
                const SizedBox(
                    height: 16.0), // Optional spacing between widgets
                Expanded(
                  flex: 1, // Half of the available space
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Question:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      Expanded(
                        child: HTMLViewer(
                          showEditButton: true,
                          cssPath: Assets.css.bootstrap.bootstrapSlateMin,
                          highlightJsCssPath: Assets.css.highlight.agate,
                          language: flashCard.questionDisplayLanguage,
                          initialText: flashCard.question,
                          onChanged: (value) {
                            flashCard.question = value;
                            Data().store.box<FlashCard>().put(flashCard);
                          },
                          onLanguageChanged: (language) {
                            flashCard.questionDisplayLanguage = language;
                            Data().store.box<FlashCard>().put(flashCard);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 16.0),
                Expanded(
                  flex: 1, // The other half of the available space
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Answer:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      SearchableDropdown(
                          items: languageMap.keys.toList(),
                          onChanged: (language) {
                            flashCard.answerInputLanguage = language;
                            Data().store.box<FlashCard>().put(flashCard);
                          },
                          initialValue: flashCard.answerInputLanguage,
                          labelText: 'Answer Input',
                          hintText:
                              'Select the language for syntax highlighting of user input...'),
                      const SizedBox(height: 8.0),
                      Expanded(
                        child: HTMLViewer(
                          showEditButton: true,
                          initialText: flashCard.answer,
                          language: flashCard.correctAnswerDislpayLanguage,
                          cssPath: Assets.css.bootstrap.bootstrapSlateMin,
                          highlightJsCssPath: Assets.css.highlight.agate,
                          onChanged: (value) {
                            flashCard.answer = value;
                            Data().store.box<FlashCard>().put(flashCard);
                          },
                          onLanguageChanged: (language) {
                            flashCard.correctAnswerDislpayLanguage = language;
                            Data().store.box<FlashCard>().put(flashCard);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
