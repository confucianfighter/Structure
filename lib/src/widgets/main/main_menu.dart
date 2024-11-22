import 'package:flutter/material.dart';
import 'dart:io'; // Add this import

import '../../settings/settings_view.dart';
import 'menu_item.dart';
import '../subjects/subject_list_view.dart';
import '../writing_prompts/writing_prompt_category_view.dart';
import '../object_box_countdown_widget.dart';
import '../../systems/object_box_timer.dart';

/// Displays a list of SampleItems.
class MainMenu extends StatefulWidget {
  // Change from StatelessWidget to StatefulWidget
  const MainMenu({
    super.key,
    this.items = const [
      MenuItem(
          id: 1,
          route: SubjectListView.routeName,
          icon: Icon(Icons.edit),
          title: 'Flash Cards'),
      MenuItem(
          id: 2,
          route: CategoriesWidget.routeName,
          icon: Icon(Icons.category),
          title: 'Writing Prompts'),
    ],
  });

  static const routeName = '/';

  final List<MenuItem> items;

  @override
  MainMenuState createState() => MainMenuState(); // Change this line
}

class MainMenuState extends State<MainMenu> {
  // Change this class to public
  // Add this class
  bool _isAlwaysOnTop = false;
  @override
  void initState() {
    super.initState();
    _isAlwaysOnTop = false;
    //TimerStateNotifier().startTimer();
  }

  Future<void> _toggleAlwaysOnTop() async {
    setState(() {
      _isAlwaysOnTop = !_isAlwaysOnTop;
    });
    final result = await Process.run(
        'lib/src/AlwaysOnTop/bin/Debug/net9.0/AlwaysOnTop.exe', // Use relative path
        [_isAlwaysOnTop.toString()]);

    if (result.exitCode != 0) {
      // Handle error if needed
      print('Error: ${result.stderr}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Menu'),
        actions: [
          ObjectBoxCountdownWidget(
            // Add ObjectBoxCountdownWidget
            countdownId: TimerID.main.id,
          ),
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

          // insert listenable builder that listends for AppState time remaining seconds from hive and displays it
          // ValueListenableBuilder(
          //   valueListenable: Hive.box<AppState>('state').listenable(),
          //   builder: (context, Box<AppState> box, _) {
          //     final appState = getAppState(); // Now it's synchronous
          //     final timeRemaining = appState.timeRemainingSeconds?.toString() ?? '0';

          //     return Text('Time Remaining: $timeRemaining');
          //   },
          // ),
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
        restorationId: 'MainMenuListView',
        itemCount: widget.items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = widget.items[index];

          return ListTile(
              title: Text(item.title),
              leading: Icon(
                //Icons.edit_rounded,
                Icons.quiz,
                color: Colors.orange,
              ),
              // add another icon to left of leading icon
              onTap: () {
                // Navigate to the details page. If the user leaves and returns to
                // the app after it has been killed while running in the
                // background, the navigation stack is restored.
                Navigator.restorablePushNamed(
                  context,
                  item.route,
                );
              });
        },
      ),
    );
  }
}
