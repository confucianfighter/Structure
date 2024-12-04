import 'package:flutter/material.dart';
import '../../data_store.dart';
import 'flash_card.dart';
import 'flash_card_editor.dart';

class FlashCardListWidget extends StatelessWidget {
  const FlashCardListWidget({super.key, required this.subject});
  final Subject subject;
  @override
  Widget build(BuildContext context) {
    final stream =
        Data().store.box<FlashCard>().query(FlashCard_.subject.equals(subject.id)).watch(triggerImmediately: true);

    return Scaffold(
      appBar: AppBar(title: const Text('FlashCards')),
      body: StreamBuilder<List<FlashCard>>(
        stream: stream.map((query) => query.find()),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final flashCards = snapshot.data!;
            return ListView.builder(
              itemCount: flashCards.length,
              itemBuilder: (context, index) {
                final flashCard = flashCards[index];
                return FlashCardWidget(
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
          newFlashCard.subject.target = subject;
          Data().store.box<FlashCard>().put(newFlashCard);
        },
        tooltip: 'Add FlashCard',
        child: const Icon(Icons.add),
      ),
    );
  }
}
