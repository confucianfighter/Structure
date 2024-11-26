import 'package:objectbox/objectbox.dart';
import 'writing_prompt_answer.dart';
import 'package:flutter/services.dart';
import 'package:toml/toml.dart';
import '../../data_store.dart';
import '../../utils/error_handling.dart';
import 'category.dart';
import '../../../objectbox.g.dart';

@Entity()
class WritingPrompt {
  @Id()
  int id = 0;

  String prompt;

  @Property(type: PropertyType.date)
  DateTime lastEdited;

  @Property(type: PropertyType.date)
  DateTime? lastTimeAnswered;

  final ToOne<Category> category = ToOne<Category>();
  static late Stream<List<WritingPrompt>>? _allWritingPromptsStream;
  @Backlink('writingPrompt')
  final answers = ToMany<WritingPromptAnswer>();

  WritingPrompt(
      {required this.prompt,
      required this.lastEdited,
      this.lastTimeAnswered,
      this.id = 0,
      Category? category}) {
    this.category.target = category ?? Category.getDefault();
  }
  static Stream<List<WritingPrompt>> getWritingPromptListStream(Category category){
    return _allWritingPromptsStream ?? Data().store
      .box<WritingPrompt>()
      .query(WritingPrompt_.category.equals(category.id))
      .watch(triggerImmediately: true)
      .map((query) => query.find());
  }
}

// function to load initial toml data
Future<void> prepopulateWritingPrompts() async {
  final tomlString = await rootBundle.loadString('assets/writing_prompts.toml');
  final tomlData = TomlDocument.parse(tomlString).toMap();
  // if writing prompt already exists update it, preserve answers, id, dateCreated, lastTimeAnswered
  // if writing prompt does not exist, create it
  final List<WritingPrompt> prompts = (tomlData['writing_prompts'] as List?)
          ?.map((e) => WritingPrompt(
                id: int.tryParse(e['id'].toString()) ?? 0,
                prompt: e['prompt'] as String,
                lastEdited: DateTime.tryParse(e['lastEdited'].toString()) ??
                    DateTime.now(),
                lastTimeAnswered: e['lastTimeAnswered'] == null
                    ? null
                    : DateTime.tryParse(e['lastTimeAnswered'].toString()) ??
                        DateTime.now(),
                category: Category.fromString(e['category'] as String),
              ))
          .toList() ??
      [];
  // get all ids
  // Go through prompts, check if id exists, if it does, update, if not, add, use runInTransaction
  Data().store.runInTransaction(TxMode.write, () {
    for (var prompt in prompts) {
      final existingPrompt = Data().store.box<WritingPrompt>().get(prompt.id);
      if (existingPrompt == null) {
        prompt.id = 0;
        Data().store.box<WritingPrompt>().put(prompt);
      } else {
        existingPrompt.prompt = prompt.prompt;
        existingPrompt.lastEdited = prompt.lastEdited;
        existingPrompt.lastTimeAnswered = prompt.lastTimeAnswered;
        existingPrompt.category.target = prompt.category.target;
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
            'category': e.category,
            'answers': e.answers.map((e) => e.id).toList(),
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
