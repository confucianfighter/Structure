import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../data_types/quiz_question.dart';

class QuestionCard extends StatefulWidget {
  final QuizQuestion question;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const QuestionCard({
    super.key,
    required this.question,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: MarkdownBody(
                    data: widget.question.question,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: widget.onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            MarkdownBody(
              data: widget.question.answer,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Tags: ${widget.question.tags.join(", ")}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
