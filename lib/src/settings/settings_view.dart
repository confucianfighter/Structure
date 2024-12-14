import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'settings_controller.dart';
import 'package:objectbox/objectbox.dart';
import 'package:Structure/src/data_store.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatefulWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late Stream<Settings?> settingsStream;

  @override
  void initState() {
    super.initState();
    // Create a stream to listen to changes in the Settings entity
    if(Data().store.box<Settings>().isEmpty()){
      Data().store.box<Settings>().put(Settings(
        themeMode: 'dark',
        homeFolderPath: '~/',
        dateModifiedMillis: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    settingsStream = Data()
        .store
        .box<Settings>()
        .query()
        .order(Settings_.dateModifiedMillis,
            flags: Order.descending)
        .watch(triggerImmediately: true)
        .map((query) => query.findFirst());
  }

  Future<void> _pickDirectory(BuildContext context) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      // Save the selected directory path in the settings
      widget.controller.updateHomeFolderPath(selectedDirectory);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Directory Selected: $selectedDirectory')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<Settings?>(
          stream: settingsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final settings = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme selection dropdown
                DropdownButton<ThemeMode>(
                  // Read the selected themeMode from the snapshot
                  value: themeModeFromString(settings.themeMode),
                  // Call the updateThemeMode method any time the user selects a theme.
                  onChanged: widget.controller.updateThemeMode,
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System Theme'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light Theme'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark Theme'),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                // Display the current directory path
                Text(
                  'Current Directory: ${settings.homeFolderPath}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                // Directory picker button
                ElevatedButton(
                  onPressed: () => _pickDirectory(context),
                  child: const Text('Select Directory for Data Storage'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
ThemeMode themeModeFromString(String value) {
  return ThemeMode.values.firstWhere(
    (e) => e.toString().split('.').last == value,
    orElse: () => throw ArgumentError('Invalid enum value: $value'),
  );
}