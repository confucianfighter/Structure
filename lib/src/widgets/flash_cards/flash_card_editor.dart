import 'package:flutter/material.dart';
import '../../data_store.dart';
import '../md/md_editor.dart';
import 'flash_card.dart';
import '../nuts_and_bolts/searchable_dropdown.dart';
import '../../data_types/code_editor/language_option.dart';
import '../code_editor/code_editor.dart';

class FlashCardEditor extends StatefulWidget {
  final int flashCardId;

  const FlashCardEditor({Key? key, required this.flashCardId})
      : super(key: key);

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
            // reset stats button
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edit Question:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  
                  const SizedBox(height: 8.0),
                  CodeEditorWidget(
                    initialCode: flashCard.question,
                    languageSelectionTitle: 'Question language',
                    languageSelectionHint: 'Allows using html or markdown',
                    onChanged: (value) {
                      flashCard.question = value;
                      Data().store.box<FlashCard>().put(flashCard);
                    },
                    onLanguageChanged: (language) {
                      flashCard.questionLanguage = language;
                      Data().store.box<FlashCard>().put(flashCard);
                    },
                  ),
                  const Divider(height: 32.0),
                  const Text(
                    'Edit Answer:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  // MdEditor for Answer
                  CodeEditorWidget(
                    initialCode: flashCard.answer,
                    language: flashCard.answerLanguage,
                    onChanged: (value) {
                      flashCard.answer = value;
                      Data().store.box<FlashCard>().put(flashCard);
                    },
                    onLanguageChanged: (language) {
                      flashCard.answerLanguage = language;
                      Data().store.box<FlashCard>().put(flashCard);
                    },
                    languageSelectionTitle: "Answer Language",
                    languageSelectionHint:
                        "This is so user answer is syntax highlighted properly",
                  ),
                  const Divider(height: 32.0),
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
