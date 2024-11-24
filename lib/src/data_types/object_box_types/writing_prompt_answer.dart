import 'package:objectbox/objectbox.dart';
import 'writing_prompt.dart';
@Entity()
class WritingPromptAnswer {
  @Id() // Automatically generated ID for ObjectBox
  int id = 0;

  String answer;
  DateTime dateAnswered;

  // Relationship to WritingPrompt (Many-to-One)
  final writingPrompt = ToOne<WritingPrompt>();

  WritingPromptAnswer({
    required this.answer,
    required this.dateAnswered,
  });
}
