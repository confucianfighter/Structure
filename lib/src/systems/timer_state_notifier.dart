// timer_state_notifier.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../app.dart';
import '../widgets/main/main_menu.dart';

class TimerStateNotifier extends ChangeNotifier {
  static final TimerStateNotifier _instance = TimerStateNotifier._internal();

  factory TimerStateNotifier() {
    return _instance;
  }

  TimerStateNotifier._internal();
  bool isExpired = false;
  int _timeRemaining = 60; // Default initial time
  Timer? _timer;

  int get timeRemaining => _timeRemaining;

  void startTimer() {
    if (_timer != null && _timer!.isActive) return; // Prevent multiple timers
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        _timeRemaining--;
        notifyListeners();
      } else {
        isExpired = true;
        MyApp.navigatorKey.currentState?.pushNamed(MainMenu.routeName);
        stopTimer();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    notifyListeners();
  }

  void resetTimer(int newTime) {
    _timeRemaining = newTime;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
