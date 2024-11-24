import 'package:objectbox/objectbox.dart';
import 'writing_prompt_answer.dart';

@Entity()
class WritingPrompt {
  @Id()
  int id = 0;

  String prompt;

  @Property(type: PropertyType.date)
  DateTime dateCreated;

  @Property(type: PropertyType.date)
  DateTime? lastTimeAnswered;

  String category;
  
  @Backlink('writingPrompt')
  final answers = ToMany<WritingPromptAnswer>();

  WritingPrompt({
    required this.prompt,
    required this.dateCreated,
    this.lastTimeAnswered,
    required this.category,
  });
}
