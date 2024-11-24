import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data_types/writing_prompt.dart';

class WritingPromptEditor extends StatelessWidget {
  const WritingPromptEditor({
    super.key,
    required this.promptId,
  });

  final String promptId;

  @override
  Widget build(BuildContext context) {
    final promptBox = Hive.box<WritingPrompt>('writing_prompts');
    final categoriesBox = Hive.box<String>('writing_prompt_categories'); // Separate box for categories

    return ValueListenableBuilder<Box<WritingPrompt>>(
      valueListenable: promptBox.listenable(),
      builder: (context, box, _) {
        final prompt = box.get(promptId);

        if (prompt == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Prompt')),
            body: const Center(child: Text("Prompt not found")),
          );
        }

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
                      box.put(prompt.id, prompt); // Update directly
                    },
                  ),
                  const SizedBox(height: 8.0),
                  ValueListenableBuilder<Box<String>>(
                    valueListenable: categoriesBox.listenable(),
                    builder: (context, categoriesBox, _) {
                      final categories = categoriesBox.values.toList();
                      return Row(
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              hint: const Text('Select a category'),
                              value: prompt.category,
                              items: categories.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (String? newCategory) {
                                if (newCategory != null) {
                                  prompt.category = newCategory;
                                  box.put(prompt.id, prompt); // Update directly
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              _showAddCategoryDialog(context, categoriesBox);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    initialValue: prompt.lastTimeAnswered != null
                        ? prompt.lastTimeAnswered.toString()
                        : "",
                    decoration:
                        const InputDecoration(labelText: 'Last Time Answered'),
                    onChanged: (value) {
                      final newDate = DateTime.tryParse(value);
                      if (newDate != null) {
                        prompt.lastTimeAnswered = newDate;
                        box.put(prompt.id, prompt); // Update directly
                      }
                    },
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          box.delete(prompt.id);
                          Navigator.pop(context); // Go back after deletion
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Placeholder for adding additional actions
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
  }

  // Function to show dialog for adding a new category
  void _showAddCategoryDialog(BuildContext context, Box<String> categoriesBox) {
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
                if (newCategory.isNotEmpty &&
                    !categoriesBox.values.contains(newCategory)) {
                  categoriesBox.add(newCategory); // Add to Hive
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
