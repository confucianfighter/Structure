import 'package:flutter/material.dart';
import '../../data_store.dart';
import '../md/md_viewer.dart';

class FlashCardPreview extends StatelessWidget {
  final FlashCard flashCard;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FlashCardPreview({
    Key? key,
    required this.flashCard,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

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
                const Text(
                  'FlashCard Preview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
                child: MdViewer(
                  content: flashCard.question,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            // FlashCard Stats
            Text('Correct: ${flashCard.timesCorrect}'),
            Text('Incorrect: ${flashCard.timesIncorrect}'),
            Text('Rating: ${flashCard.userRating}'),
          ],
        ),
      ),
    );
  }
}
