import 'package:flutter/material.dart';

class SubjectManager extends StatefulWidget {
  final Function(List<String>) onSubjectsChanged;

  const SubjectManager({Key? key, required this.onSubjectsChanged}) : super(key: key);

  @override
  _SubjectManagerState createState() => _SubjectManagerState();
}

class _SubjectManagerState extends State<SubjectManager> {
  final TextEditingController _subjectController = TextEditingController();
  List<String> _subjects = [];

  void _addSubject() {
    final subject = _subjectController.text.trim();
    if (subject.isNotEmpty && !_subjects.contains(subject)) {
      setState(() {
        _subjects.add(subject);
        _subjectController.clear();
      });
      widget.onSubjectsChanged(_subjects);
    }
  }

  void _removeSubject(String subject) {
    setState(() {
      _subjects.remove(subject);
    });
    widget.onSubjectsChanged(_subjects);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _subjectController,
          decoration: InputDecoration(
            labelText: 'Add Subject',
            suffixIcon: IconButton(
              icon: Icon(Icons.add),
              onPressed: _addSubject,
            ),
          ),
          onSubmitted: (_) => _addSubject(),
        ),
        Wrap(
          spacing: 8.0,
          children: _subjects.map((subject) {
            return Chip(
              label: Text(subject),
              deleteIcon: Icon(Icons.close),
              onDeleted: () => _removeSubject(subject),
            );
          }).toList(),
        ),
      ],
    );
  }
}
