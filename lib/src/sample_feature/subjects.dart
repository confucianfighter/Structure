import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> addSubject(String subject) async {
  var box = Hive.box<String>('subjects');
  if (!box.values.contains(subject)) {
    await box.add(subject);
  }
}

List<String> getAllSubjects() {
  var box = Hive.box<String>('subjects');
  return box.values.toList();
}

Future<void> removeSubject(String subject) async {
  var box = Hive.box<String>('subjects');
  final key = box.keys.firstWhere(
    (k) => box.get(k) == subject,
    orElse: () => null,
  );
  if (key != null) {
    await box.delete(key);
  }
}

Future<void> clearAllSubjects() async {
  var box = Hive.box<String>('subjects');
  await box.clear();
}
