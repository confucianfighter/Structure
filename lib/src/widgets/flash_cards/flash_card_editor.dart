import 'package:flutter/material.dart';
import '../../data_store.dart';

class FlashCardEditor extends StatelessWidget {
  final int flashCardId;

  const FlashCardEditor({super.key, required this.flashCardId});

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

        return Scaffold(
          appBar: AppBar(title: const Text('Edit FlashCard')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  initialValue: flashCard.question,
                  decoration: const InputDecoration(labelText: 'Question'),
                  onChanged: (value) {
                    flashCard.question = value;
                    Data().store.box<FlashCard>().put(flashCard);
                  },
                ),
                TextFormField(
                  initialValue: flashCard.answer,
                  decoration: const InputDecoration(labelText: 'Answer'),
                  onChanged: (value) {
                    flashCard.answer = value;
                    Data().store.box<FlashCard>().put(flashCard);
                  },
                ),
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
        );
      },
    );
  }
}
