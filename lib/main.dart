import 'dart:developer';
import 'package:Structure/src/data_types/state.dart';
import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/data_types/quiz_question.dart';
import 'src/data_types/object_box_types/writing_prompt.dart';
import 'package:path_provider/path_provider.dart';
// Generated file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();
  // log the path to the Hive data directory
  log('Hive data directory: ${dir.path}');
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  await Hive.initFlutter();
  Hive.registerAdapter(QuizQuestionAdapter());
  await Hive.openBox<QuizQuestion>('quiz_questions');

  await Hive.openBox<String>('subjects');

  await Hive.openBox<String>('writing_prompt_categories');
  await Hive.deleteBoxFromDisk('writing_prompts');

  Hive.registerAdapter(AppStateAdapter());
  await Hive.openBox<AppState>('state');

  // start the timer
  //CountdownTimer().start();
  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.

  runApp(
    // MultiProvider(
    //   providers: [
    //     // ChangeNotifierProvider<TimerStateNotifier>(
    //     //   create: (_) => TimerStateNotifier(),
    //     // ),

    //     // Add more providers as needed
    //   ],
    /*child:*/ MyApp(settingsController: settingsController),
  );
  //);
}
