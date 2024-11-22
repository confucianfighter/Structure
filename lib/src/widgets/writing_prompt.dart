import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toml/toml.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
// import conversion package
part 'writing_prompt.g.dart';

@HiveType(typeId: 4)
class WritingPrompt {
  @HiveField(0)
  String id;

  @HiveField(1)
  String prompt;

  @HiveField(2)
  DateTime dateCreated;

  @HiveField(3)
  DateTime? lastTimeAnswered;

  @HiveField(4)
  String category;

  WritingPrompt({
    required this.id,
    required this.prompt,
    required this.dateCreated,
    this.lastTimeAnswered,
    required this.category,
  });
}

@HiveType(typeId: 3)
class WritingPromptAnswer {
  @HiveField(0)
  String id;

  @HiveField(1)
  String answer;

  @HiveField(2)
  DateTime dateAnswered;

  WritingPromptAnswer({
    required this.id,
    required this.answer,
    required this.dateAnswered,
  });
}

// Hive operations for WritingPrompt
Future<void> addWritingPrompt(WritingPrompt prompt) async {
  var box = Hive.box<WritingPrompt>('writing_prompts');
  await box.put(prompt.id, prompt);
}

Future<WritingPrompt?> getWritingPrompt(String id) async {
  var box = Hive.box<WritingPrompt>('writing_prompts');
  return box.get(id);
}

List<WritingPrompt> getAllWritingPrompts() {
  var box = Hive.box<WritingPrompt>('writing_prompts');
  return box.values.toList();
}

Future<void> removeWritingPrompt(String id) async {
  var box = Hive.box<WritingPrompt>('writing_prompts');
  await box.delete(id);
}

// Hive operations for PromptAnswer
Future<void> addPromptAnswer(WritingPromptAnswer answer) async {
  var box = Hive.box<WritingPromptAnswer>('prompt_answers');
  await box.put(answer.id, answer);
}

Future<WritingPromptAnswer?> getPromptAnswer(String id) async {
  var box = Hive.box<WritingPromptAnswer>('prompt_answers');
  return box.get(id);
}

List<WritingPromptAnswer> getAllPromptAnswers() {
  var box = Hive.box<WritingPromptAnswer>('prompt_answers');
  return box.values.toList();
}

Future<void> removePromptAnswer(String id) async {
  var box = Hive.box<WritingPromptAnswer>('prompt_answers');
  await box.delete(id);
}

Future<void> prepopulatePrompts() async {
  var box = Hive.box<WritingPrompt>('writing_prompts');

  // Load the TOML file
  final tomlString = await rootBundle.loadString('assets/writing_prompts.toml');
  final tomlData = TomlDocument.parse(tomlString).toMap();

  // Convert TOML to WritingPrompt objects
  final List<WritingPrompt> prompts = (tomlData['writing_prompts'] as List?)
      ?.map((e) => WritingPrompt(
            id: e['id'] as String,
            prompt: e['prompt'] as String,
            dateCreated: DateTime.parse(e['dateCreated'] as String),
            category: e['category'] as String,
          ))
      .toList() ?? [];

  // Update or add prompts in Hive
  for (var prompt in prompts) {
    final existingPrompt = box.get(prompt.id);
    if (existingPrompt == null) {
      // Add new prompt if it doesn't exist
      await box.put(prompt.id, prompt);
    } else if (existingPrompt.prompt != prompt.prompt ||
        existingPrompt.dateCreated != prompt.dateCreated) {
      // Update prompt if data has changed
      await box.put(prompt.id, prompt);
    }
  }
}
// function to prepopulate categories by extracting from writing prompts:
Future<void> prepopulateCategories() async {
  var box = Hive.box<WritingPrompt>('writing_prompts');
  var categoryBox = Hive.box<String>('writing_prompt_categories');
  var categories = box.values.map((e) => e.category).toSet().toList();
  for (var category in categories) {
    if (!categoryBox.values.contains(category)) {
      await categoryBox.put(DateTime.now().toString(), category);
    }
  }
}
// function to go through categories and remove any that are not in the list
Future<void> removeUnusedCategories() async {
  var box = Hive.box<WritingPrompt>('writing_prompts');
  var categories = box.values.map((e) => e.category).toSet().toList();
  var categoryBox = Hive.box<String>('writing_prompt_categories');
  var categoryList = categoryBox.values.toList();
  for (var category in categoryList) {
    if (!categories.contains(category)) {
      await categoryBox.delete(
          categoryBox.keys.firstWhere((k) => categoryBox.get(k) == category));
    }
  }
}
