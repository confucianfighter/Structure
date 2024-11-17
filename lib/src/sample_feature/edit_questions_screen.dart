import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'quiz_question.dart';

class EditQuestionsScreen extends StatefulWidget {
  const EditQuestionsScreen({super.key, required this.subject});
  final String subject;
  static const String routeName = '/edit-questions';

  @override
  _EditQuestionsScreenState createState() => _EditQuestionsScreenState();
}

class _EditQuestionsScreenState extends State<EditQuestionsScreen> {
  late Box<QuizQuestion> _quizBox;

  @override
  void initState() {
    super.initState();
    _quizBox = Hive.box<QuizQuestion>('quiz_questions');
  }

  void _addQuestion() async {
    final newQuestion = QuizQuestion(
      question: "",
      answer: "",
      id: DateTime.now().toString(),
      tags: [],
    );
    await _quizBox.put(newQuestion.id, newQuestion);
    setState(() {});
  }

  void _removeQuestion(String id) async {
    await _quizBox.delete(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final questions = _quizBox.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Questions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addQuestion,
            tooltip: 'Add Question',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    initialValue: question.question,
                    decoration: const InputDecoration(labelText: 'Question'),
                    onChanged: (value) async {
                      question.question = value;
                      await _quizBox.put(question.id, question);
                      setState(() {});
                    },
                  ),
                  TextFormField(
                    initialValue: question.answer,
                    decoration: const InputDecoration(labelText: 'Answer'),
                    onChanged: (value) async {
                      question.answer = value;
                      await _quizBox.put(question.id, question);
                      setState(() {});
                    },
                  ),
                  TextFormField(
                    initialValue: question.tags.join(", "),
                    decoration: const InputDecoration(
                        labelText: 'Tags (comma-separated)'),
                    onChanged: (value) async {
                      question.tags =
                          value.split(',').map((tag) => tag.trim()).toList();
                      await _quizBox.put(question.id, question);
                      setState(() {});
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _removeQuestion(question.id),
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addQuestion,
        tooltip: 'Add Question',
        child: const Icon(Icons.add),
      ),
    );
  }
}
