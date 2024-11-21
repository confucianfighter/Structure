import 'dart:ffi';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'quiz_question.dart';
import 'subjects.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'QuestionCard.dart';
import 'QuizQuestionEditorCard.dart';
import 'package:hive_flutter/hive_flutter.dart';

class QuestionListWidget extends StatelessWidget {
  const QuestionListWidget({Key? key, required this.subject}) : super(key: key);

  final String subject;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subject: $subject'),
      ),
      body: ValueListenableBuilder<Box<QuizQuestion>>(
        valueListenable: Hive.box<QuizQuestion>('quiz_questions').listenable(),
        builder: (context, box, _) {
          // Filter questions for the current subject
          final questions = box.values
              .where((question) => question.subjects.contains(subject))
              .toList();

          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              return QuestionCard(
                question: question,
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizQuestionEditorCard(
                        question_id: question.id,
                      ),
                    ),
                  );
                },
                onDelete: () async {
                  await Hive.box<QuizQuestion>('quiz_questions')
                      .delete(question.id);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newQuestion = QuizQuestion(
            id: DateTime.now().toString(),
            question: "",
            answer: "",
            tags: [],
            subjects: [subject],
          );
          await Hive.box<QuizQuestion>('quiz_questions')
              .put(newQuestion.id, newQuestion);
        },
        tooltip: 'Add Question',
        child: const Icon(Icons.add),
      ),
    );
  }
}
