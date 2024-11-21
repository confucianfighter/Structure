import 'package:flutter/material.dart';
import 'quiz_question.dart';
import 'subjects.dart';
import 'package:hive_flutter/hive_flutter.dart';

class QuizQuestionEditorCard extends StatelessWidget {
  const QuizQuestionEditorCard({
    super.key,
    required this.question_id,
  });

  final String question_id;

  @override
  Widget build(BuildContext context) {
    // Get a listenable for the specific box
    final questionBox = Hive.box<QuizQuestion>('quiz_questions');

    return ValueListenableBuilder<Box<QuizQuestion>>(
      valueListenable: questionBox.listenable(),
      builder: (context, box, _) {
        // Retrieve the specific question by its ID
        final question = box.get(question_id);

        if (question == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Question')),
            body: const Center(child: Text("Question not found")),
          );
        }

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
                      box.put(question.id, question); // Update directly
                    },
                  ),
                  TextFormField(
                    initialValue: question.answer,
                    decoration: const InputDecoration(labelText: 'Answer'),
                    onChanged: (value) {
                      question.answer = value;
                      box.put(question.id, question); // Update directly
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
                        box.put(question.id, question); // Update directly
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
                      box.put(question.id, question); // Update directly
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          box.delete(question.id);
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
