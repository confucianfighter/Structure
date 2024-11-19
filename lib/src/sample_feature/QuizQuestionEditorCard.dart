import 'package:flutter/material.dart';
import 'quiz_question.dart';
import 'subjects.dart';

class QuizQuestionEditorCard extends StatelessWidget {
  const QuizQuestionEditorCard({
    super.key,
    required this.question_id,
    required this.onUpdate,
  });

  final String question_id;
  final Function(QuizQuestion) onUpdate;

  Future<QuizQuestion> _initializeQuestion() async {
    try {
      final fetchedQuestion = await getQuizQuestion(question_id);
      if (fetchedQuestion != null) {
        return fetchedQuestion;
      } else {
        throw Exception("Question not found");
      }
    } catch (error) {
      throw Exception("Error initializing question: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuizQuestion>(
      future: _initializeQuestion(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}"),
          );
        } else if (!snapshot.hasData) {
          return const Center(
            child: Text("Question not found"),
          );
        }

        QuizQuestion question = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Question'),
          ),
          body: Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: question.question,
                    decoration: const InputDecoration(labelText: 'Question'),
                    onChanged: (value) {
                      question.question = value;
                      onUpdate(question); // Notify parent of update
                    },
                  ),
                  TextFormField(
                    initialValue: question.answer,
                    decoration: const InputDecoration(labelText: 'Answer'),
                    onChanged: (value) {
                      question.answer = value;
                      onUpdate(question); // Notify parent of update
                    },
                  ),
                  DropdownButton<String>(
                    hint: const Text('Select an option'),
                    value: question.subjects.isNotEmpty
                        ? question.subjects[0]
                        : null,
                    items: getAllSubjects().map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        if (question.subjects.isEmpty) {
                          question.subjects.add(newValue);
                        } else {
                          question.subjects[0] = newValue;
                        }
                        onUpdate(question); // Notify parent of update
                      }
                    },
                  ),
                  TextFormField(
                    initialValue: question.tags.join(", "),
                    decoration: const InputDecoration(
                        labelText: 'Tags (comma-separated)'),
                    onChanged: (value) {
                      question.tags =
                          value.split(',').map((tag) => tag.trim()).toList();
                      onUpdate(question); // Notify parent of update
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          removeQuizQuestion(question.id);
                          Navigator.pop(context); // Go back after deletion
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Optionally handle adding images or a link
                        },
                        icon: const Icon(Icons.link),
                        label: const Text('Add Link/Image'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
