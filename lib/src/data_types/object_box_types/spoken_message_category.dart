import '../../data_store.dart';
import 'dart:async';

@Entity()
class SpokenMessageCategory {
  @Id(assignable: true)
  int id = 0;
  @Unique()
  String name = 'Uncategorized';
  // allow for an empty constructor
  SpokenMessageCategory({required this.id, required this.name});

  static SpokenMessageCategory fromString(String catName) {
    // retrieve category from name
    var category = Data()
        .store
        .box<SpokenMessageCategory>()
        .query(SpokenMessageCategory_.name.equals(catName))
        .build()
        .findFirst();
    if (category == null) {
      category = SpokenMessageCategory(id: 0, name: catName);
      Data().store.box<SpokenMessageCategory>().put(category);
    }
    return category;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpokenMessageCategory && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  static SpokenMessageCategory getDefault() {
    // find or create 'Uncategorized' category
    var category = Data()
        .store
        .box<SpokenMessageCategory>()
        .query(SpokenMessageCategory_.name.equals('Orphaned'))
        .build()
        .findFirst();
    if (category == null) {
      category = SpokenMessageCategory(id: 0, name: 'Orphaned');
      Data().store.box<SpokenMessageCategory>().put(category);
    }
    return category;
  }

  static Future<SpokenMessageCategory?> AddIfNotExists(String name) async {
    SpokenMessageCategory? category = Data()
        .store
        .box<SpokenMessageCategory>()
        .query(SpokenMessageCategory_.name.equals(name))
        .build()
        .findFirst();
    if (category == null) {
      Data().store.box<SpokenMessageCategory>().put(SpokenMessageCategory(id: 0, name: name));
      category = Data()
              .store
              .box<SpokenMessageCategory>()
              .query(SpokenMessageCategory_.name.equals(name))
              .build()
              .findFirst() ??
          category;
    }
    return category;
  }

  static bool AddOrUpdate(SpokenMessageCategory category) {
    //check if id exists, if it does, update, if not, add
    final existingSpokenMessageCategory = Data()
        .store
        .box<SpokenMessageCategory>()
        .query(SpokenMessageCategory_.id.equals(category.id))
        .build()
        .findFirst();
    if (existingSpokenMessageCategory == null) {
      category.id = 0;
      Data().store.box<SpokenMessageCategory>().put(category);
      return true;
    } else {
      existingSpokenMessageCategory.name = category.name;
      Data().store.box<SpokenMessageCategory>().put(existingSpokenMessageCategory);
      return true;
    }
  }
}
