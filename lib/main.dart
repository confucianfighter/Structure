import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/widgets/quiz_question.dart';
import 'src/widgets/writing_prompt.dart';

void main() async {
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

  Hive.registerAdapter(WritingPromptAdapter());
  await Hive.openBox<WritingPrompt>('writing_prompts');

  Hive.registerAdapter(WritingPromptAnswerAdapter());
 
  await Hive.openBox<WritingPromptAnswer>('writing_prompt_answers');
  await prepopulatePrompts();
  await prepopulateCategories();
  await removeUnusedCategories();
  
  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(settingsController: settingsController));
}
