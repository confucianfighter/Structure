import 'package:flutter/material.dart';
import '../../data_store.dart';
import 'subject_card.dart';
import 'subject_editor.dart';
import '../flash_cards/flash_card_list_widget.dart';
class SubjectListWidget extends StatelessWidget {
  const SubjectListWidget({super.key});
  static const route = '/subjects';
  @override
  Widget build(BuildContext context) {
    final stream = Data().store.box<Subject>().query().watch(triggerImmediately: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Subjects')),
      body: StreamBuilder<List<Subject>>(
        stream: stream.map((query) => query.find()),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final subjects = snapshot.data!;
            return ListView.builder(
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                return SubjectCard(
                  subject: subject,
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubjectEditor(subjectId: subject.id),
                      ),
                    );
                  },
                  onDelete: () async {
                    Data().store.box<Subject>().remove(subject.id);
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading subjects'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newSubject = Subject(
            id: 0,
            name: 'New Subject',
            description: '',
            color: '#FFFFFF',
          );
          Data().store.box<Subject>().put(newSubject);
        },
        tooltip: 'Add Subject',
        child: const Icon(Icons.add),
      ),
    );
  }
}
