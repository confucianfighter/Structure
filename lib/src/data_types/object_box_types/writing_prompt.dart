import 'writing_prompt_answer.dart';
import 'package:flutter/services.dart';
import 'package:toml/toml.dart';
import '../../data_store.dart';
import 'dart:developer';

@Entity()
class WritingPrompt {
  @Id()
  int id = 0;

  @Unique()
  String prompt;

  @Property(type: PropertyType.date)
  DateTime lastEdited;

  @Property(type: PropertyType.date)
  DateTime? lastTimeAnswered;

  ToOne<Category> category = ToOne<Category>();

  static late Stream<List<WritingPrompt>>? _allWritingPromptsStream;
  @Backlink('writingPrompt')
  ToMany<WritingPromptAnswer> answers = ToMany<WritingPromptAnswer>();

  WritingPrompt({
    required this.prompt,
    required this.lastEdited,
    this.lastTimeAnswered,
    this.id = 0,
  });

  static QueryResult addIfNotExists(String prompt) {
    final existingPrompt = Data()
        .store
        .box<WritingPrompt>()
        .query(WritingPrompt_.prompt.equals(prompt))
        .build()
        .findFirst();
    if (existingPrompt != null) {
      return QueryResult(
          id: existingPrompt.id,
          message: "Prompt already exists",
          status: QueryResultType.alreadyExisted,
          data: existingPrompt);
    }
    final newPrompt = WritingPrompt(prompt: prompt, lastEdited: DateTime.now());
    Data().store.box<WritingPrompt>().put(newPrompt);
    return QueryResult(
        id: newPrompt.id,
        message: "Prompt added successfully",
        status: QueryResultType.success);
  }

  void addAnswer(WritingPromptAnswer answer) {
    answers.add(answer);
    Data().store.box<WritingPrompt>().put(this);
  }
}

enum QueryResultType { success, alreadyExisted, error }

class QueryResult<T> {
  final String? message;
  final int? id;
  final T? data;
  final QueryResultType status;
  const QueryResult({required this.status, this.id, this.message, this.data});
}

// function to load initial toml data
Future<void> prepopulateWritingPrompts() async {
  // Load the TOML file and parse it
  final tomlString = await rootBundle.loadString('assets/writing_prompts.toml');
  final tomlData = TomlDocument.parse(tomlString).toMap();
  final List<Category> categories = [];
  // Process and prepare data outside the transaction
  final List<WritingPrompt> prompts = tomlData['writing_prompts'] is List
      ? await Future.wait((tomlData['writing_prompts'] as List).map((e) async {
          final category = e['category'] == null
              ? null
              : await Category.AddIfNotExists(e['category'].toString());

          final prompt = WritingPrompt(
            id: int.tryParse(e['id'].toString()) ?? 0,
            prompt: e['prompt'] as String,
            lastEdited: DateTime.tryParse(e['lastEdited']?.toString() ?? '') ??
                DateTime.now(),
            lastTimeAnswered: e['lastTimeAnswered'] == null
                ? null
                : DateTime.tryParse(e['lastTimeAnswered']?.toString() ?? '') ??
                    DateTime.now(),
          );

          if (category != null) {
            prompt.category.target = category;
          }

          return prompt;
        }))
      : [];

  Data().store.runInTransaction(TxMode.write, () {
    List<WritingPrompt> finalList = [];
    for (var prompt in prompts) {
      WritingPrompt? existingPrompt;
      existingPrompt = Data().store.box<WritingPrompt>().get(prompt.id);
      if (existingPrompt == null) {
        // check if identical prompt exists
        existingPrompt = Data()
            .store
            .box<WritingPrompt>()
            .query(WritingPrompt_.prompt.equals(prompt.prompt))
            .build()
            .findFirst();
        if (existingPrompt == null) {
          Data().store.box<WritingPrompt>().put(prompt);
        }
      } else {
        prompt.id = existingPrompt.id;
        Data().store.box<WritingPrompt>().put(existingPrompt);
      }
    }
  });
}

// function to serialize data to toml
Future<String> serializeData() async {
  final prompts = Data().store.box<WritingPrompt>().getAll();
  final List<Map<String, dynamic>> promptList = prompts
      .map((e) => {
            'id': e.id,
            'prompt': e.prompt,
            'lastEdited': e.lastEdited.toIso8601String(),
            'lastTimeAnswered': e.lastTimeAnswered?.toIso8601String(),
            'category': e.category.target?.name,
            'answers': e.answers.map((ans) => ans.id).toList(),
          })
      .toList();
  final toml = TomlDocument.fromMap({'writing_prompts': promptList});
  return toml.toString();
}

// function to add prompt to database
Future<void> addPrompt(WritingPrompt prompt) async {
  Data().store.box<WritingPrompt>().put(prompt);
}

Future<void> removePrompt(int id) async {
  Data().store.box<WritingPrompt>().remove(id);
}

Future<Stream<Query<WritingPrompt>>> watchAllWritingPrompts() async {
  // query for any changes to writing prompt table
  return Data()
      .store
      .box<WritingPrompt>()
      .query()
      .watch(triggerImmediately: true);
}
