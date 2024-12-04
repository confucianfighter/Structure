import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import '../../data_store.dart';

class FlashCardSequenceItemWidget extends StatelessWidget {
  final int sequenceItemId;

  const FlashCardSequenceItemWidget({
    Key? key,
    required this.sequenceItemId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final flashCardSequenceBox = Data().store.box<FlashCardSequence>();
    final subjectBox = Data().store.box<Subject>();

    // Stream for the FlashCardSequence
    final flashCardSequenceQuery = flashCardSequenceBox
        .query(FlashCardSequence_.id.equals(sequenceItemId))
        .watch(triggerImmediately: true)
        .map((query) => query.findFirst());

    // Stream for all Subjects
    final subjectsQuery = subjectBox
        .query()
        .watch(triggerImmediately: true)
        .map((query) => query.find());

    return StreamBuilder<FlashCardSequence?>(
      stream: flashCardSequenceQuery,
      builder: (context, flashCardSnapshot) {
        if (flashCardSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (flashCardSnapshot.hasError) {
          return Text('Error: ${flashCardSnapshot.error}');
        } else if (!flashCardSnapshot.hasData ||
            flashCardSnapshot.data == null) {
          return Text('Flashcard sequence not found.');
        } else {
          final flashCardSequence = flashCardSnapshot.data!;

          return StreamBuilder<List<Subject>>(
            stream: subjectsQuery,
            builder: (context, subjectsSnapshot) {
              if (subjectsSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (subjectsSnapshot.hasError) {
                return Text('Error: ${subjectsSnapshot.error}');
              } else if (!subjectsSnapshot.hasData ||
                  subjectsSnapshot.data!.isEmpty) {
                return Text('No subjects available.');
              } else {
                final subjects = subjectsSnapshot.data!;
                final selectedSubject = flashCardSequence.subject.target;

                return Card(
                  child: ListTile(
                    title: Text('Flash Card Sequence ${flashCardSequence.id}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Number of Cards: ${flashCardSequence.number_of_cards}'),
                        SizedBox(height: 8.0),
                        Text('Subject:'),
                        DropdownButton<Subject>(
                          value: selectedSubject,
                          hint: Text('Select a subject'),
                          items: subjects.map((Subject subject) {
                            return DropdownMenuItem<Subject>(
                              value: subject,
                              child: Text(subject.name),
                            );
                          }).toList(),
                          onChanged: (Subject? newSubject) {
                            if (newSubject != null) {
                              flashCardSequence.subject.target = newSubject;
                              Data().store.box<FlashCardSequence>().put(flashCardSequence);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}
