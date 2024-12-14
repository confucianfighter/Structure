import 'package:flutter/material.dart';
import '../../data_store.dart';
import 'subject_card.dart';
import 'subject_editor.dart';
class SubjectListWidget extends StatefulWidget {
  const SubjectListWidget({super.key});
  static const route = '/subjects';
  @override _SubjectListWidget createState() => _SubjectListWidget();
}
class _SubjectListWidget extends State<SubjectListWidget> {
  final Stream<List<Subject>> _streamBuilder = Data().store.box<Subject>().query().watch(triggerImmediately: true).map((query) => query.find());
  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: AppBar(title: const Text('Subjects')),
      body: StreamBuilder<List<Subject>>(
        stream: _streamBuilder,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final subjects = snapshot.data!;
            // make sure that the All and Orphaned subjects are always at the top
            subjects.sort((a, b) {
              if (a.name == 'All') return -1;
              if (b.name == 'All') return 1;
              if (a.name == 'Orphaned') return -1;
              if (b.name == 'Orphaned') return 1;
              return a.name.compareTo(b.name);
            });
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
