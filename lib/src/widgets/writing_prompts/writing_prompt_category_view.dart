import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'writing_prompt_list_widget.dart';

class CategoriesWidget extends StatelessWidget {
  const CategoriesWidget({super.key});
  static const String routeName = '/writing_prompt_categories';
  @override
  Widget build(BuildContext context) {
    final categoriesBox = Hive.box<String>('writing_prompt_categories');

    return Scaffold(
      appBar: AppBar(
        title: const Text('writing_prompt_categories'),
      ),
      body: ValueListenableBuilder(
        valueListenable: categoriesBox.listenable(),
        builder: (context, Box<String> box, _) {
          final categories = box.values.toList();

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              return ListTile(
                title: Text(category),
                leading: const Icon(
                  Icons.category,
                  color: Colors.blue,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: Text(
                              'Are you sure you want to delete the category "$category"?'),
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                            TextButton(
                              child: const Text('Delete'),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ],
                        );
                      },
                    );
                    if (confirmDelete == true) {
                      await box.delete(box.keys
                          .firstWhere((key) => box.get(key) == category));
                    }
                  },
                ),
                onTap: () {
                  // Navigate to the WritingPromptListWidget for the selected category
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WritingPromptListWidget(category: category),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context, categoriesBox),
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, Box<String> categoriesBox) {
    String newCategory = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextField(
            onChanged: (value) {
              newCategory = value;
            },
            decoration: const InputDecoration(hintText: 'Enter category name'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (newCategory.isNotEmpty &&
                    !categoriesBox.values.contains(newCategory)) {
                  categoriesBox.add(newCategory);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
