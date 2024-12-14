import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import '../../data_store.dart';

class FlashCardSequenceItemWidget extends StatefulWidget {
  final int sequenceItemId;

  const FlashCardSequenceItemWidget({
    super.key,
    required this.sequenceItemId,
  });

  @override
  _FlashCardSequenceItemWidgetState createState() =>
      _FlashCardSequenceItemWidgetState();
}

class _FlashCardSequenceItemWidgetState
    extends State<FlashCardSequenceItemWidget> {
  late Box<FlashCardSequence> flashCardSequenceBox;
  late Box<Subject> subjectBox;
  FlashCardSequence? flashCardSequence;
  List<Subject> subjects = [];
  Subject? selectedSubject;

  @override
  void initState() {
    super.initState();
    flashCardSequenceBox = Data().store.box<FlashCardSequence>();
    subjectBox = Data().store.box<Subject>();

    loadData();
  }

  void loadData() {
    // Load the flashcard sequence
    flashCardSequence =
        flashCardSequenceBox.get(widget.sequenceItemId);
    
    if (flashCardSequence != null) {
      selectedSubject = flashCardSequence!.subject.target;
    }

    // Load all subjects
    subjects = Data().store.box<Subject>().getAll();
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (flashCardSequence == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      child: ListTile(
        title: Text('Flash Card Sequence ${flashCardSequence!.id}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Number of Cards: ${flashCardSequence!.number_of_cards}'),
            const SizedBox(height: 8.0),
            const Text('Subject:'),
            DropdownButton<int>(
              value: selectedSubject?.id,
              hint: const Text('Select a subject'),
              items: subjects.map((Subject subject) {
                return DropdownMenuItem<int>(
                  value: subject.id,
                  child: Text(subject.name),
                );
              }).toList(),
              onChanged: (int? newSubjectId) {
                if (newSubjectId != null) {
                  setState(() {
                    selectedSubject = subjects.firstWhere((subject) => subject.id == newSubjectId);
                    flashCardSequence!.subject.target = selectedSubject;
                    flashCardSequenceBox.put(flashCardSequence!);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
