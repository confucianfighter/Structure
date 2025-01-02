import '../../data_store.dart';
import 'package:flutter/material.dart';
import 'spoken_message_list_widget.dart';

class SpokenMessageCategoriesWidget extends StatelessWidget {
  const SpokenMessageCategoriesWidget({super.key});
  static const String routeName = '/spoken_message_categories';
  @override
  Widget build(BuildContext context) {
    late var queryBuilder = Data().store.box<SpokenMessageCategory>().query();
    print("building spoken message category list.");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spoken Message Categories'),
      ),
      body: StreamBuilder<List<SpokenMessageCategory>>(
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
                              SpokenMessageListWidget(category: null),
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
                        String newSpokenMessageCategory = categoryName;
                        TextEditingController controller =
                            TextEditingController(text: categoryName);
                        showDialog(
                          context: context,
                          builder: (dialogueContext) {
                            return AlertDialog(
                              title: const Text('Rename SpokenMessageCategory'),
                              content: TextField(
                                controller: controller,
                                onChanged: (value) {
                                  newSpokenMessageCategory = value;
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
                                    if (newSpokenMessageCategory.isNotEmpty) {
                                      category.name = newSpokenMessageCategory;
                                      Data()
                                          .store
                                          .box<SpokenMessageCategory>()
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
                          if (category != SpokenMessageCategory.getDefault()) {
                            Data().store.box<SpokenMessageCategory>().remove(category.id);
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
                            SpokenMessageListWidget(category: category),
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
        onPressed: () => _showAddSpokenMessageCategoryDialog(context),
        tooltip: 'Add SpokenMessageCategory',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddSpokenMessageCategoryDialog(BuildContext context) {
    String newSpokenMessageCategory = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New SpokenMessageCategory'),
          content: TextField(
            onChanged: (value) {
              newSpokenMessageCategory = value;
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
                if (newSpokenMessageCategory.isNotEmpty) {
                  SpokenMessageCategory.AddIfNotExists(newSpokenMessageCategory);
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
