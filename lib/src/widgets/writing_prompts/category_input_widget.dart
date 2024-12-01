import 'package:flutter/material.dart';
import '../../data_store.dart';

class CategoryInputWidget extends StatefulWidget {
  final List<Category> allCategories;
  final WritingPrompt prompt;
  final Function(WritingPrompt) onPromptUpdated;

  const CategoryInputWidget({
    super.key,
    required this.allCategories,
    required this.prompt,
    required this.onPromptUpdated,
  });

  @override
  _CategoryInputWidgetState createState() => _CategoryInputWidgetState();
}

class _CategoryInputWidgetState extends State<CategoryInputWidget> {
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Initialize the selected category from the prompt
    _selectedCategory = widget.prompt.category.target;
  }

  void _updateCategory(Category category) {
    setState(() {
      _selectedCategory = category;
      widget.prompt.category.target = category; // Update the ToOne relationship
    });
    widget.onPromptUpdated(widget.prompt);
  }

  void _showAddCategoryDialog() {
    final TextEditingController dialogController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextField(
            controller: dialogController,
            decoration: const InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final newCategoryName = dialogController.text.trim();
                if (newCategoryName.isNotEmpty) {
                  final Category? newCategory =
                      await Category.AddIfNotExists(newCategoryName);
                  if (newCategory != null) {
                    setState(() {
                      widget.allCategories.add(newCategory);
                    });
                    _updateCategory(newCategory);
                  }
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButton<Category>(
            isExpanded: true,
            value: _selectedCategory,
            hint: const Text('Select a Category'),
            items: widget.allCategories.map((category) {
              return DropdownMenuItem<Category>(
                value: category,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (Category? selected) {
              if (selected != null) {
                _updateCategory(selected);
              }
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _showAddCategoryDialog,
        ),
      ],
    );
  }
}
