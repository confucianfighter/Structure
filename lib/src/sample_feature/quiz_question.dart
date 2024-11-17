import 'package:json_annotation/json_annotation.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:collection';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'quiz_question.g.dart';

@HiveType(typeId: 0)
class QuizQuestion {
  @HiveField(0)
  String question;

  @HiveField(1)
  String answer;

  @HiveField(2)
  String id;

  @HiveField(3)
  int timesAnsweredCorrectly;

  @HiveField(4)
  DateTime? mostRecentCorrectAnswer;

  @HiveField(5)
  List<String> tags;

  @HiveField(6)
  List<String> subjects;

  @HiveField(7)
  String? questionImage;

  @HiveField(8)
  String? answerImage;

  @HiveField(9)
  String? link;

  QuizQuestion({
    required this.question,
    required this.answer,
    required this.id,
    this.timesAnsweredCorrectly = 0,
    this.mostRecentCorrectAnswer,
    this.tags = const [],
    this.subjects = const [],
    this.questionImage,
    this.answerImage,
    this.link,
  });
}

Future<void> addQuizQuestion(QuizQuestion question) async {
  var box = Hive.box<QuizQuestion>('quiz_questions');
  await box.put(question.id, question);
}

Future<QuizQuestion?> getQuizQuestion(String id) async {
  var box = Hive.box<QuizQuestion>('quiz_questions');
  var question = box.get(id);
  return question;
}

List<QuizQuestion> getAllQuizQuestions() {
  var box = Hive.box<QuizQuestion>('quiz_questions');
  return box.values.toList();
}
// Get all questions of a certain subject
List<QuizQuestion> getQuestionsBySubject(String subject) {
  var box = Hive.box<QuizQuestion>('quiz_questions');
  return box.values.where((question) => question.subjects.contains(subject)).toList();
}

Future<void> removeQuizQuestion(String id) async {
  var box = Hive.box<QuizQuestion>('quiz_questions');
  await box.delete(id);
}


