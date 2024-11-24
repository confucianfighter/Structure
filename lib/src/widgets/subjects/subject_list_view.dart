import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Ensure you have the Hive package set up
import '../quiz_questions/question_list_widget.dart';
import '../../settings/settings_view.dart';
// Import CRUD operations

class SubjectListView extends StatelessWidget {
  const SubjectListView({super.key});
  static const String routeName = '/subjects';

  @override
  Widget build(BuildContext context) {
    final subjectBox = Hive.box<String>('subjects'); // Replace 'subjects' with your Hive box name

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
      body: ValueListenableBuilder(
        valueListenable: subjectBox.listenable(),
        builder: (context, Box<String> box, _) {
          final subjects = box.values.toList();

          return ListView.builder(
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
                    onPressed: () async {
                      final confirmDelete = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Deletion'),
                            content: Text(
                                'Are you sure you want to delete the subject "$subject"?'),
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
                        await box.delete(subject);
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            QuestionListWidget(subject: subject),
                      ),
                    );
                  },
                );
                
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddSubjectDialog(context, subjectBox);
        },
        tooltip: 'Add Subject',
        child: Icon(Icons.add),
      ),
      
    );
  }

  void _showAddSubjectDialog(BuildContext context, Box<String> subjectBox) {
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
                  subjectBox.put(newSubject, newSubject); // Add subject to Hive
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
