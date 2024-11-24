import 'settings/settings_controller.dart';
import 'app.dart';
import 'package:flutter/material.dart';
import 'systems/timer_state_notifier.dart';

class MyAppWrapper extends StatefulWidget {
  final SettingsController settingsController;

  const MyAppWrapper({super.key, required this.settingsController});

  @override
  _MyAppWrapperState createState() => _MyAppWrapperState();
}

class _MyAppWrapperState extends State<MyAppWrapper> {
  @override
  void initState() {
    super.initState();
    TimerStateNotifier().startTimer();
  }

  @override
  void dispose() {
    TimerStateNotifier().stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyApp(settingsController: widget.settingsController);
  }
}
