import 'package:json_annotation/json_annotation.dart';
import 'quiz_question.dart';
part 'subject.g.dart';

@JsonSerializable()
class Subject {
  String name; // Name of the subject
  String? description; // Optional description of the subject
  List<QuizQuestion> questions; // List of quiz questions

  Subject({
    required this.name,
    this.description,
    this.questions = const [],
  });

  /// Factory constructor to create a `Subject` from JSON
  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);

  /// Method to convert a `Subject` to JSON
  Map<String, dynamic> toJson() => _$SubjectToJson(this);
}
