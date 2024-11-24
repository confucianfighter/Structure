// countdown_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../systems/timer_state_notifier.dart';

class CountdownWidget extends StatelessWidget {
  const CountdownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerStateNotifier>(
      builder: (context, timerState, child) {
        return Text(
          '${timerState.timeRemaining} seconds',
          style: const TextStyle(fontSize: 24),
        );
      },
    );
  }
}
