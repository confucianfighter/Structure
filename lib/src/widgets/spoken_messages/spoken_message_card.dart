import '../../data_types/object_box_types/writing_prompt.dart';
import 'package:flutter/material.dart';
import '../../data_store.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SpokenMessageCard extends StatefulWidget {
  final SpokenMessage message;

  const SpokenMessageCard({
    super.key,
    required this.message,
  });

  @override
  _SpokenMessageCardState createState() => _SpokenMessageCardState();
}

class _SpokenMessageCardState extends State<SpokenMessageCard> {
  bool _isEditing = false;
  bool _isRecording = false;
  late SpokenMessage _message;
  @override
  initState() {
    super.initState();
    _message = widget.message;
  }

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
                  child: TextFormField(
                    initialValue: widget.message.text,
                    decoration: const InputDecoration(labelText: 'Prompt'),
                    onChanged: (value) {
                      setState(() {
                        _message.text = value;
                      });
                      Data().store.box<SpokenMessage>().put(_message);
                    },
                  ),
                ),
                IconButton(
                  icon: _isEditing
                      ? const Icon(Icons.edit)
                      : const Icon(Icons.done),
                  onPressed: () => setState(() {
                    _isEditing = !_isEditing;
                  }),
                ),
                IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => Data()
                        .store
                        .box<WritingPrompt>()
                        .remove(widget.message.id)),
                IconButton(
                  icon: _isRecording
                      ? const Icon(Icons.record_voice_over)
                      : const Icon(Icons.record_voice_over_outlined),
                  onPressed: () {
                    if (!_isRecording) {
                      setState(() {
                        _isRecording = true;
                      });
                    }
                  },
                )
              ],
            ),
            const SizedBox(height: 8.0),

            // Category
            Text(
              'Category: ${widget.message.category.target?.name ?? "Uncategorized"}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),

            // Last answered (optional)
            if (widget.message.lastTimeUsed != null)
              Text(
                'Last Used: ${widget.message.lastTimeUsed!.toLocal()}',
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
