import 'package:flutter/material.dart';
import 'question_list_widget.dart';
import '../settings/settings_view.dart';
import 'subjects.dart'; // Import the CRUD operations

class SubjectListView extends StatefulWidget {
  const SubjectListView({Key? key}) : super(key: key);
  static const String routeName = '/subjects';
  @override
  _SubjectListViewState createState() => _SubjectListViewState();
}

class _SubjectListViewState extends State<SubjectListView> {
  List<String> subjects = [];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  void _loadSubjects() {
    setState(() {
      subjects = getAllSubjects();
    });
  }

  void _addSubject(String subject) async {
    await addSubject(subject);
    _loadSubjects();
  }

  void _removeSubject(String subject) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content:
              Text('Are you sure you want to delete the subject "$subject"?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await removeSubject(subject);
      _loadSubjects();
    }
  }

  void _showAddSubjectDialog() {
    String newSubject = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Subject'),
          content: TextField(
            onChanged: (value) {
              newSubject = value;
            },
            decoration: InputDecoration(hintText: "Enter subject name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (newSubject.isNotEmpty) {
                  _addSubject(newSubject);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subjects'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: subjects.length + 1, // +1 for the "All" option
        itemBuilder: (context, index) {
          if (index == 0) {
            // The "All" option
            return ListTile(
              title: Text('All'),
              leading: Icon(
                Icons.list,
                color: Colors.blue,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionListWidget(subject: 'All'),
                  ),
                );
              },
            );
          } else {
            final subject = subjects[index - 1];
            return ListTile(
              title: Text(subject),
              leading: Icon(
                Icons.quiz,
                color: Colors.orange,
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.purple),
                onPressed: () {
                  _removeSubject(subject);
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionListWidget(subject: subject),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSubjectDialog,
        tooltip: 'Add Subject',
        child: Icon(Icons.add),
      ),
    );
  }
}
