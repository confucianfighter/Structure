import '../../data_types/object_box_types/writing_prompt.dart';
import 'package:flutter/material.dart';
import '../../data_store.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class WritingPromptCard extends StatefulWidget {
  final WritingPrompt prompt;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WritingPromptCard({
    super.key,
    required this.prompt,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  _WritingPromptCardState createState() => _WritingPromptCardState();
}

class _WritingPromptCardState extends State<WritingPromptCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for prompt and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: MarkdownBody(
                    data: widget.prompt.prompt,
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

            // Category
            Text(
              'Category: ${widget.prompt.category.target?.name ?? "Uncategorized"}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),

            // Date created
            Text(
              'Last Edited: ${widget.prompt.lastEdited.toLocal()}',
              style: const TextStyle(color: Colors.grey),
            ),

            // Last answered (optional)
            if (widget.prompt.lastTimeAnswered != null)
              Text(
                'Last Answered: ${widget.prompt.lastTimeAnswered!.toLocal()}',
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
