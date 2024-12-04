import 'package:flutter/material.dart';
// Add this import

import '../../settings/settings_view.dart';
import 'menu_item.dart';
import '../writing_prompts/writing_prompt_category_view.dart';
import '../object_box_countdown_widget.dart';
import '../app_bar/pin_button.dart';
//import '../../data_types/object_box_types/countdown.dart';
import '../../data_store.dart';
import '../sequences/sequence_list.dart';
import '../subjects/subject_list_widget.dart';


/// Displays a list of SampleItems.
class MainMenu extends StatelessWidget {
  const MainMenu({
    super.key,
    this.items = const [
      MenuItem(
          id: 1,
          route: SubjectListWidget.route,
          icon: Icons.edit,
          title: 'Flash Cards'),
      MenuItem(
          id: 2,
          route: CategoriesWidget.routeName,
          icon: Icons.category,
          title: 'Writing Prompts'),
      // Create sequences menu item
      MenuItem(
          id: 3,
          route: SequenceListWidget.route,
          icon: Icons.timeline,
          title: 'Sequences'),
      
      
    ],
  });

  static const routeName = '/';

  final List<MenuItem> items;

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
          PinToTopButton(),
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
      body: ListView.builder(
        restorationId: 'MainMenuListView',
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];

          return ListTile(
              title: Text(item.title),
              leading: Icon(
                item.icon,
                color: Colors.orange,
              ),
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
