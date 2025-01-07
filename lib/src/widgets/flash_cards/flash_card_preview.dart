import 'package:flutter/material.dart';
import '../../data_store.dart';

class FlashCardPreview extends StatelessWidget {
  final FlashCard flashCard;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FlashCardPreview({
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
            // Top Row with Edit and Delete Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            // Scrollable Markdown Preview
            Container(
              height: 120, // Fixed height for preview
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: SingleChildScrollView(
                child: Text(flashCard.question),
              ),
            ),
            const SizedBox(height: 8.0),
            // FlashCard Stats
            Row(children: [
              SizedBox(width: 20),
              Text('Correct: ${flashCard.timesCorrect}'),
              SizedBox(width: 20),
              Text('Incorrect: ${flashCard.timesIncorrect}'),
              SizedBox(width: 20),
              Text('Rating: ${flashCard.userRating}')
            ]),
          ],
        ),
      ),
    );
  }
}
