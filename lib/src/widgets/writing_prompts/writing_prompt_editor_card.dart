import 'package:flutter/material.dart';
// import 'package:objectbox/objectbox.dart';
// import '../../data_types/object_box_types/writing_prompt.dart';
import '../../data_store.dart';
// import '../../../objectbox.g.dart';
// import '../../data_types/object_box_types/category.dart';
class WritingPromptEditor extends StatelessWidget {
  const WritingPromptEditor({
    super.key,
    required this.promptId,
  });

  final int promptId;

  @override
  Widget build(BuildContext context) {
    final promptStream = Data().store.box<WritingPrompt>().query(WritingPrompt_.id.equals(promptId)).watch(triggerImmediately: true);
    final categoryStream = Data().store.box<Category>().query().watch(triggerImmediately: true);

    return StreamBuilder<Query<WritingPrompt>>(
      stream: promptStream,
      builder: (context, promptSnapshot) {
        if (promptSnapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Prompt')),
            body: Center(child: Text('Error: ${promptSnapshot.error}')),
          );
        }

        if (!promptSnapshot.hasData || promptSnapshot.data!.find().isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Prompt')),
            body: const Center(child: Text('Prompt not found')),
          );
        }

        final prompt = promptSnapshot.data!.find().first;

        return StreamBuilder<Query<Category>>(
          stream: categoryStream,
          builder: (context, categorySnapshot) {
            if (categorySnapshot.hasError) {
              return Center(child: Text('Error: ${categorySnapshot.error}'));
            }

            final List<Category> categories = categorySnapshot.hasData
                ? categorySnapshot.data!.find().toList()
                : List<Category>.empty();

            return Scaffold(
              appBar: AppBar(
                title: const Text('Edit Writing Prompt'),
              ),
              body: Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        initialValue: prompt.prompt,
                        decoration: const InputDecoration(labelText: 'Prompt'),
                        onChanged: (value) {
                          prompt.prompt = value;
                          Data().store.box<WritingPrompt>().put(prompt);
                        },
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButton<Category>(
                              hint: const Text('Select a category'),
                              value: prompt.category.target,
                              items: categories.map((category) {
                                return DropdownMenuItem<Category>(
                                  value: category,
                                  child: Text(category.name),
                                );
                              }).toList(),
                              onChanged: (Category? newCategory) {
                                if (newCategory != null) {
                                  prompt.category.target = newCategory;
                                  Data().store.box<WritingPrompt>().put(prompt);
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              _showAddCategoryDialog(context, categories);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        initialValue: prompt.lastTimeAnswered?.toString() ?? '',
                        decoration:
                            const InputDecoration(labelText: 'Last Time Answered'),
                        onChanged: (value) {
                          final newDate = DateTime.tryParse(value);
                          if (newDate != null) {
                            prompt.lastTimeAnswered = newDate;
                            Data().store.box<WritingPrompt>().put(prompt);
                          }
                        },
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Data().store.box<WritingPrompt>().remove(prompt.id);
                              Navigator.pop(context); // Go back after deletion
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Placeholder for additional actions
                            },
                            icon: const Icon(Icons.save),
                            label: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context, List<Category> categories) {
    final TextEditingController categoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newCategory = categoryController.text.trim();
                if (newCategory.isNotEmpty && !categories.contains(newCategory)) {
                  // Create a dummy WritingPrompt to store the category
                  final dummyPrompt = WritingPrompt(
                    prompt: '',
                    lastEdited: DateTime.now(),
                    category: Category.getDefault(),
                  );
                  Data().store.box<WritingPrompt>().put(dummyPrompt);
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
