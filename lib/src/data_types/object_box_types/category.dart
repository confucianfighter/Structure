import '../../../objectbox.g.dart';
import 'package:objectbox/objectbox.dart';
import '../../data_store.dart';
import 'package:toml/toml.dart';
import 'package:flutter/services.dart';
import 'writing_prompt.dart';
import 'dart:async';
import 'dart:developer';
import '../../utils/error_handling.dart';

@Entity()
class Category {
  @Id(assignable: true)
  int id = 0;
  @Unique()
  String name = 'Uncategorized';
  // allow for an empty constructor
  Category({required this.id, required this.name});

  static Category fromString(String catName) {
    // retrieve category from name
    var category = Data()
        .store
        .box<Category>()
        .query(Category_.name.equals(catName))
        .build()
        .findFirst();
    if (category == null) {
      category = Category(id: 0, name: catName);
      Data().store.box<Category>().put(category);
    }
    return category;
  }

  static Category getDefault() {
    // find or create 'Uncategorized' category
    var category = Data()
        .store
        .box<Category>()
        .query(Category_.name.equals('Uncategorized'))
        .build()
        .findFirst();
    if (category == null) {
      category = Category(id: 0, name: 'Uncategorized');
      Data().store.box<Category>().put(category);
    }
    return category;
  }

  static Future<Category?> AddIfNotExists(String name) async {
    Category? category = Data()
        .store
        .box<Category>()
        .query(Category_.name.equals(name))
        .build()
        .findFirst();
    if (category == null) {
      await Data().store.box<Category>().putAsync(Category(id: 0, name: name));
      return Data()
          .store
          .box<Category>()
          .query(Category_.name.equals(name))
          .build()
          .findFirst();
    } else {
      return category;
    }
  }

  static bool AddOrUpdate(Category category) {
    //check if id exists, if it does, update, if not, add
    final existingCategory = Data()
        .store
        .box<Category>()
        .query(Category_.id.equals(category.id))
        .build()
        .findFirst();
    if (existingCategory == null) {
      category.id = 0;
      Data().store.box<Category>().put(category);
      return true;
    } else {
      existingCategory.name = category.name;
      Data().store.box<Category>().put(existingCategory);
      return true;
    }
  }
}

// function to load initial toml data
Future<void> loadInitialCategoryData() async {
  // define 'Uncategorized' category
  // add if unique
  Category.AddIfNotExists("Uncategorized");
  final tomlString = await defaultOnErr<String>(
      () => rootBundle.loadString('assets/categories.toml'), '');
  final tomlData = TomlDocument.parse(tomlString).toMap();
  // if category already exists update it, preserve id
  // if category does not exist, create it
  final List<Category> catsFromToml = (tomlData['categories'] as List?)
          ?.map((e) => Category(
                id: e['id'] as int,
                name: e['name'] as String,
              ))
          .toList() ??
      [];

  // Go through categories, check if id exists, if it does, update, if not, add, use runInTransaction
  // Grab the categories of all existing writing prompts
  final Set<Category> catSet = Data()
      .store
      .box<WritingPrompt>()
      .query(WritingPrompt_.category.notNull())
      .build()
      .find()
      .map((e) => e.category.target)
      .whereType<Category>()
      .toSet();
  // loop through the categories from the toml file and add them to the catSet
  for (var cat in catsFromToml) {
    catSet.add(cat);
  }
  Data().store.runInTransaction(TxMode.write, () {
    for (var category in catsFromToml) {
      final existingCategory = Data().store.box<Category>().get(category.id);
      if (existingCategory == null) {
        category.id = 0;
        Data().store.box<Category>().put(category);
      } else {
        existingCategory.name = category.name;
        Data().store.box<Category>().put(existingCategory);
      }
    }
  });
}

// function to extract all categories from writing prompts and return them as List<Category>
List<Category> extractCategoriesFromWritingPrompts() {
  final existingCategories = Data()
      .store
      .box<WritingPrompt>()
      .query(WritingPrompt_.category.notNull())
      .build()
      .find()
      .map((e) => e.category.target)
      .whereType<Category>()
      .toSet();
  return existingCategories.map((e) => e).toList();
}

Future<T> defaultOnErr<T>(Future<T> Function() func, T default_value) async {
  try {
    return await func();
  } catch (e) {
    log('Error: $e');
    return default_value;
  }
}
