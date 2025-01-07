import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data_store.dart';
import 'flash_card_preview.dart';
import 'flash_card_editor.dart';
import '../../utils/flashcard_assistant.dart';

class FlashCardListWidget extends StatefulWidget {
  const FlashCardListWidget({super.key, required this.subject});
  final Subject subject;
  @override
  _FlashCardListWidget createState() => _FlashCardListWidget();
}

class _FlashCardListWidget extends State<FlashCardListWidget> {
  late Stream<List<FlashCard>> _streamBuilder;
  bool _isAssistantOpen = false;
  final FlashcardAssistant _flashcardAssistant = FlashcardAssistant();
  List<FlashCard> _flashCards = [];
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _streamBuilder = (widget.subject.name == 'All')
        ? Data()
            .store
            .box<FlashCard>()
            .query()
            .watch(triggerImmediately: true)
            .map((query) => query.find())
            .asBroadcastStream()
        : (widget.subject.name == 'Orphaned')
            ? Data()
                .store
                .box<FlashCard>()
                .query(FlashCard_.subject.isNull())
                .watch(triggerImmediately: true)
                .map((query) => query.find())
                .asBroadcastStream()
            : Data()
                .store
                .box<FlashCard>()
                .query(FlashCard_.subject.equals(widget.subject.id))
                .watch(triggerImmediately: true)
                .map((query) => query.find())
                .asBroadcastStream();
  }

  void _submitAssistantRequest() async {
    final value = _textController.text;
    if (value.isNotEmpty) {
      // Fetch existing flashcards
      // Generate new flashcards
      final newFlashcards =
          await _flashcardAssistant.generateFlashcards(value, _flashCards);

      // Add new flashcards to the data store
      setState(() {
        for (var flashcard in newFlashcards) {
          flashcard.subject.target = widget.subject;
          Data().store.box<FlashCard>().put(flashcard);
        }
      });

      // Clear the text field
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlashCards'),
        actions: [
          IconButton(
            icon: _isAssistantOpen
                ? const Icon(Icons.assistant)
                : const Icon(Icons.assistant_outlined),
            onPressed: () {
              setState(() {
                _isAssistantOpen = !_isAssistantOpen;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isAssistantOpen)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: RawKeyboardListener(
                      focusNode: _focusNode,
                      onKey: (event) {
                        if (event.isControlPressed &&
                            event.logicalKey == LogicalKeyboardKey.enter) {
                          _submitAssistantRequest();
                        }
                      },
                      child: TextFormField(
                        controller: _textController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Enter your message for the assistant',
                          hintText:
                              'Describe the cards you would like to generate...',
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _submitAssistantRequest,
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<List<FlashCard>>(
              stream: _streamBuilder,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _flashCards = snapshot.data!;

                  return ListView.builder(
                    itemCount: _flashCards.length,
                    itemBuilder: (context, index) {
                      final flashCard = _flashCards[index];
                      return FlashCardPreview(
                        flashCard: flashCard,
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FlashCardEditor(flashCardId: flashCard.id),
                            ),
                          );
                        },
                        onDelete: () async {
                          Data().store.box<FlashCard>().remove(flashCard.id);
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading FlashCards'));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newFlashCard = FlashCard(
            id: 0,
            question: 'New Question',
            answer: 'New Answer',
            answerInputLanguage: 'plainText',
          );

          newFlashCard.questionDisplayLanguage = 'html';
          newFlashCard.correctAnswerDislpayLanguage = 'html';
          newFlashCard.answerInputLanguage = 'plainText';
          newFlashCard.subject.target = widget.subject;
          Data().store.box<FlashCard>().put(newFlashCard);
        },
        tooltip: 'Add FlashCard',
        child: const Icon(Icons.add),
      ),
    );
  }
}
