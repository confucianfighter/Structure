import 'package:flutter/material.dart';
import 'dart:io'; // Add this import

import '../settings/settings_view.dart';
import 'menu_item.dart';
import 'edit_questions_screen.dart';
import 'subjects.dart';

/// Displays a list of SampleItems.
class SubjectListView extends StatefulWidget {
  // Change from StatelessWidget to StatefulWidget
  const SubjectListView({super.key, this.items = const []});

  static const routeName = '/subjects';

  final List<MenuItem> items;

  @override
  SubjectListViewState createState() =>
      SubjectListViewState(); // Change this line
}

class SubjectListViewState extends State<SubjectListView> {
  // Change this class to public
  // Add this class
  bool _isAlwaysOnTop = false;
  // create a subjects property
  List<String> subjects = [];
  // load subjects from file
  @override
  void initState() {
    super.initState();
    setState(() {
      subjects = getAllSubjects();
    });
  }

  Future<void> _toggleAlwaysOnTop() async {
    setState(() {
      _isAlwaysOnTop = !_isAlwaysOnTop;
    });
    final result = await Process.run(
      'lib/src/AlwaysOnTop/bin/Debug/net9.0/AlwaysOnTop.exe', // Use relative path
      [_isAlwaysOnTop.toString()],
    );
    if (result.exitCode != 0) {
      // Handle error if needed
      print('Error: ${result.stderr}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Subjects'),
          actions: [
            IconButton(
              icon: Icon(_isAlwaysOnTop
                  ? Icons.push_pin
                  : Icons.push_pin_outlined), // Change icon based on state
              onPressed: _toggleAlwaysOnTop, // Toggle always on top
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Navigate to the settings page. If the user leaves and returns
                // to the app after it has been killed while running in the
                // background, the navigation stack is restored.
                Navigator.restorablePushNamed(context, SettingsView.routeName);
              },
            ),
          ],
        ),

        // To work with lists that may contain a large number of items, it’s best
        // to use the ListView.builder constructor.
        //
        // In contrast to the default ListView constructor, which requires
        // building all Widgets up front, the ListView.builder constructor lazily
        // builds Widgets as they’re scrolled into view.
        body: ListView.builder(
            // Providing a restorationId allows the ListView to restore the
            // scroll position when a user leaves and returns to the app after it
            // has been killed while running in the background.
            restorationId: 'SubjectListView',
            itemCount: widget.items.length,
            itemBuilder: (BuildContext context, int index) {
              final subject = subjects[index];
              return Column(children: [
                ListTile(
                  title: Text(subject),
                  leading: Icon(
                    Icons.quiz,
                    color: Colors.orange,
                  ),
                  onTap: () {
                    Navigator.restorablePushNamed(
                      context,
                      EditQuestionsScreen.routeName,
                      arguments: subject,
                    );
                  },
                ),
              ]);
            }));
  }
}
