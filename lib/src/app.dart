import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'widgets/main/main_menu.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'widgets/subjects/subject_list_view.dart';
import 'widgets/writing_prompts/writing_prompt_category_view.dart';
import 'systems/object_box_timer.dart';
import 'widgets/sequences/sequence_list.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  // constructor. const means it creates a compile-time constant, which implies that settingsController is also constat.
  const MyApp(
      // curly braces mean we are using named parameters
      {
    // the key is the uuid of the widget, it is used to identify the widget in the widget tree
    super.key,
    // required means that the parameter is mandatory
    required this.settingsController,
  });
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  // final means that the variable is immutable after initialization, at runtime.
  // const means that it needs to be fully predetermined at compile time.
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    ObjectBoxTimer().startCountdown( 
      seconds: 30,
      onTimerEnd: () => MyApp.navigatorKey.currentState?.pushNamed(MainMenu.routeName)
    );
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  // case QuestionListWidget.routeName:
                  //   return QuestionListWidget(
                  //       subject: ModalRoute.of(context)!.settings.arguments
                  //           as String);
                  case SubjectListView.routeName:
                    return const SubjectListView();
                  case SequenceListWidget.route:
                    return const SequenceListWidget();
                  case CategoriesWidget.routeName:
                    return const CategoriesWidget();
                  case MainMenu.routeName:
                  // fall through to the default case
                  default:
                    // as there is no explicit call to the constructor or routeName, I'm assuming this is the entry point.
                    return const MainMenu();
                }
              },
            );
          },
        );
      },
    );
  }
}
