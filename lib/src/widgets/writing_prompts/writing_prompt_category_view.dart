import '../../data_types/object_box_types/category.dart';
import '../../data_store.dart';
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import '../../../objectbox.g.dart';
import 'writing_prompt_list_widget.dart';

class CategoriesWidget extends StatelessWidget {
  const CategoriesWidget({super.key});
  static const String routeName = '/writing_prompt_categories';
  @override
  Widget build(BuildContext context) {
    late var queryBuilder = Data().store.box<Category>().query();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Writing Prompt Categories'),
      ),
      body: StreamBuilder<List<Category>>(
        stream: queryBuilder
            .watch(triggerImmediately: true)
            .map((query) => query.find()),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading categories'));
          } else if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            final categories = snapshot.data!;
            return ListView.builder(
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    title: const Text('All'),
                    leading: const Icon(
                      Icons.list,
                      color: Colors.blue,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WritingPromptListWidget(category: null),
                        ),
                      );
                    },
                  );
                }
                final category = categories[index - 1];
                final categoryName = category.name;
                return ListTile(
                  title: Text(category.name),
                  leading: const Icon(
                    Icons.category,
                    color: Colors.blue,
                  ),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white54),
                      onPressed: () async {
                        String newCategory = categoryName;
                        TextEditingController controller =
                            TextEditingController(text: categoryName);
                        showDialog(
                          context: context,
                          builder: (dialogueContext) {
                            return AlertDialog(
                              title: const Text('Rename Category'),
                              content: TextField(
                                controller: controller,
                                onChanged: (value) {
                                  newCategory = value;
                                },
                                decoration: const InputDecoration(
                                    hintText: 'Enter new category name'),
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Save'),
                                  onPressed: () {
                                    if (newCategory.isNotEmpty) {
                                      category.name = newCategory;
                                      Data()
                                          .store
                                          .box<Category>()
                                          .put(category);
                                    }
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.purple),
                      onPressed: () async {
                        final confirmDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: Text(
                                  'Are you sure you want to delete the category "$categoryName"?'),
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
                          if (category != Category.getDefault()) {
                            Data().store.box<Category>().remove(category.id);
                          }
                        }
                      },
                    ),
                  ] //children
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
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
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
                if (newCategory.isNotEmpty) {
                  Category.AddIfNotExists(newCategory);
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
