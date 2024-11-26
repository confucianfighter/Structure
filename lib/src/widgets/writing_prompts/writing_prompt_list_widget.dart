// Import necessary packages
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import '../../data_types/object_box_types/writing_prompt.dart';
import '../../data_store.dart'; // Adjust the import path as necessary
import 'WritingPromptCard.dart';
import 'writing_prompt_editor_card.dart';
import '../../../objectbox.g.dart'; // This is the generated file by ObjectBox
import '../../data_types/object_box_types/category.dart';
class WritingPromptListWidget extends StatelessWidget {
  const WritingPromptListWidget({super.key, required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    // Build the query based on the category
    late var queryBuilder = Data().store.box<WritingPrompt>().query();
    if (category != Category.getDefault()) {
      queryBuilder = Data().store.box<WritingPrompt>().query(WritingPrompt_.category.equals(category.id));
    }
    
    final stream = queryBuilder.watch(triggerImmediately: true);

    return Scaffold(
      appBar: AppBar(
        title: Text('Category: $category'),
      ),
      body: StreamBuilder<List<WritingPrompt>>(
        stream: stream.map((query) => query.find()),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<WritingPrompt> prompts = snapshot.data!;
            return ListView.builder(
              itemCount: prompts.length,
              itemBuilder: (context, index) {
                final prompt = prompts[index];
                return WritingPromptCard(
                  prompt: prompt,
                  onEdit: () {
                    // Navigate to the editor page
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
                    // Remove the prompt using ObjectBox
                    Data().store.box<WritingPrompt>().remove(prompt.id);
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading prompts'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Add a new blank writing prompt
          final newPrompt = WritingPrompt(
            prompt: "",
            lastEdited: DateTime.now(),
            category: category,
          );
          Data().store.box<WritingPrompt>().put(newPrompt);
        },
        tooltip: 'Add Prompt',
        child: const Icon(Icons.add),
      ),
    );
  }
}
