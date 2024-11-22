import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'writing_prompt.dart';
import 'WritingPromptCard.dart';
import 'writing_prompt_editor_card.dart';

class WritingPromptListWidget extends StatelessWidget {
  const WritingPromptListWidget({Key? key, required this.category})
      : super(key: key);

  final String category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category: $category'),
      ),
      body: ValueListenableBuilder<Box<WritingPrompt>>(
        valueListenable:
            Hive.box<WritingPrompt>('writing_prompts').listenable(),
        builder: (context, box, _) {
          // Filter prompts for the current category
          final prompts = category == "All"
              ? box.values.toList()
              : box.values
                  .where((prompt) => prompt.category == category)
                  .toList();

          return ListView.builder(
            itemCount: prompts.length,
            itemBuilder: (context, index) {
              final prompt = prompts[index];
              return WritingPromptCard(
                prompt: prompt,
                onEdit: () {
                  // Navigate to an editor page or show an edit dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WritingPromptEditor(
                        promptId: prompt.id,
                      ),
                    ),
                  );
                },
                onDelete: () async {
                  await Hive.box<WritingPrompt>('writing_prompts')
                      .delete(prompt.id);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Add a new blank writing prompt
          final newPrompt = WritingPrompt(
            id: DateTime.now().toString(),
            prompt: "",
            dateCreated: DateTime.now(),
            category: category,
          );
          await Hive.box<WritingPrompt>('writing_prompts')
              .put(newPrompt.id, newPrompt);
        },
        tooltip: 'Add Prompt',
        child: const Icon(Icons.add),
      ),
    );
  }
}
