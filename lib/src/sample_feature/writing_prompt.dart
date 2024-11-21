import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'writing_prompt.g.dart';

@HiveType(typeId: 2)
class WritingPrompt {
  @HiveField(0)
  String id;

  @HiveField(1)
  String prompt;

  @HiveField(2)
  DateTime dateCreated;

  @HiveField(3)
  DateTime? lastTimeAnswered;

  WritingPrompt({
    required this.id,
    required this.prompt,
    required this.dateCreated,
    this.lastTimeAnswered,
  });
}

@HiveType(typeId: 3)
class PromptAnswer {
  @HiveField(0)
  String id;

  @HiveField(1)
  String answer;

  @HiveField(2)
  DateTime dateAnswered;

  PromptAnswer({
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
Future<void> addPromptAnswer(PromptAnswer answer) async {
  var box = Hive.box<PromptAnswer>('prompt_answers');
  await box.put(answer.id, answer);
}

Future<PromptAnswer?> getPromptAnswer(String id) async {
  var box = Hive.box<PromptAnswer>('prompt_answers');
  return box.get(id);
}

List<PromptAnswer> getAllPromptAnswers() {
  var box = Hive.box<PromptAnswer>('prompt_answers');
  return box.values.toList();
}

Future<void> removePromptAnswer(String id) async {
  var box = Hive.box<PromptAnswer>('prompt_answers');
  await box.delete(id);
}
