import 'package:flutter/material.dart';
import '../../data_store.dart';

class FlashCardWidget extends StatelessWidget {
  final FlashCard flashCard;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FlashCardWidget({
    super.key,
    required this.flashCard,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              flashCard.question,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(flashCard.answer),
            const SizedBox(height: 8.0),
            Text('Correct: ${flashCard.timesCorrect}'),
            Text('Incorrect: ${flashCard.timesIncorrect}'),
            Text('Rating: ${flashCard.userRating}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
                IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
