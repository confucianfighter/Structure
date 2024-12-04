import 'package:flutter/material.dart';
import '../../data_store.dart';

class SubjectEditor extends StatelessWidget {
  final int subjectId;

  const SubjectEditor({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context) {
    final stream = Data()
        .store
        .box<Subject>()
        .query(Subject_.id.equals(subjectId))
        .watch(triggerImmediately: true);

    return StreamBuilder<List<Subject>>(
      stream: stream.map((query) => query.find()),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Subject')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Subject')),
            body: const Center(child: Text('Subject not found')),
          );
        }

        final subject = snapshot.data!.first;

        return Scaffold(
          appBar: AppBar(title: const Text('Edit Subject')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextFormField(
                  initialValue: subject.name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (value) {
                    subject.name = value;
                    Data().store.box<Subject>().put(subject);
                  },
                ),
                TextFormField(
                  initialValue: subject.description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (value) {
                    subject.description = value;
                    Data().store.box<Subject>().put(subject);
                  },
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Data().store.box<Subject>().remove(subject.id);
                    Navigator.pop(context);
                  },
                  child: const Text('Delete Subject'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
