import 'package:objectbox/objectbox.dart';
import 'writing_prompt.dart';
import '../../data_store.dart';
@Entity()
class WritingPromptAnswer {
  @Id() // Automatically generated ID for ObjectBox
  int id = 0;

  String answer;

  DateTime dateAnswered;

  ToOne<WritingPrompt> writingPrompt = ToOne<WritingPrompt>();
  
  WritingPromptAnswer({
    required this.answer,
    required this.dateAnswered,
  });
}
