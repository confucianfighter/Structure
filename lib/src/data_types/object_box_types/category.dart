import '../../data_store.dart';
import 'package:toml/toml.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../utils/error_handling.dart';
import 'dart:collection';

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static Category getDefault() {
    // find or create 'Uncategorized' category
    var category = Data()
        .store
        .box<Category>()
        .query(Category_.name.equals('Orphaned'))
        .build()
        .findFirst();
    if (category == null) {
      category = Category(id: 0, name: 'Orphaned');
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
      Data().store.box<Category>().put(Category(id: 0, name: name));
      category = Data()
              .store
              .box<Category>()
              .query(Category_.name.equals(name))
              .build()
              .findFirst() ??
          category;
    }
    return category;
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
