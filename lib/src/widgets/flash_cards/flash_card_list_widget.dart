import 'package:flutter/material.dart';
import '../../data_store.dart';
import 'flash_card_preview.dart';
import 'flash_card_editor.dart';

class FlashCardListWidget extends StatefulWidget {
  const FlashCardListWidget({super.key, required this.subject});
  final Subject subject;
  @override
  _FlashCardListWidget createState() => _FlashCardListWidget();
}

class _FlashCardListWidget extends State<FlashCardListWidget> {
  late Stream<List<FlashCard>> _streamBuilder;
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
        : (widget.subject.name == 'Orphaned')
            ? Data()
                .store
                .box<FlashCard>()
                .query(FlashCard_.subject.isNull())
                .watch(triggerImmediately: true)
                .map((query) => query.find())
            : Data()
                .store
                .box<FlashCard>()
                .query(FlashCard_.subject.equals(widget.subject.id))
                .watch(triggerImmediately: true)
                .map((query) => query.find());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FlashCards')),
      body: StreamBuilder<List<FlashCard>>(
        stream: _streamBuilder,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // if subject is all populate with all flashcards from all subjects

            final flashCards = snapshot.data!;
            return ListView.builder(
              itemCount: flashCards.length,
              itemBuilder: (context, index) {
                final flashCard = flashCards[index];
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newFlashCard = FlashCard(
            id: 0,
            question: 'New Question',
            answer: 'New Answer',
          );
          newFlashCard.questionDisplayLanguage = 'html';
          newFlashCard.correctAnswerDislpayLanguage = 'html';
          newFlashCard.answerInputLanguage = 'html';
          newFlashCard.subject.target = widget.subject;
          Data().store.box<FlashCard>().put(newFlashCard);
        },
        tooltip: 'Add FlashCard',
        child: const Icon(Icons.add),
      ),
    );
  }
}
