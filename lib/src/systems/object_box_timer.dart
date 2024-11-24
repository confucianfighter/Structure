// timer_state_notifier.dart
import 'dart:async';
import '../app.dart';
import '../data_types/object_box_types/countdown.dart';
import 'package:objectbox/objectbox.dart';

enum TimerID {
  main(id: 1);

  final int id;

  const TimerID({required this.id});
}

class ObjectBoxTimer {
  static final ObjectBoxTimer _instance = ObjectBoxTimer._internal();
  factory ObjectBoxTimer() {
    return _instance;
  }
  ObjectBoxTimer._internal();
  void startCountdown({required int seconds, required Function onTimerEnd}) {
    Countdown countdown =
        Countdown(id: TimerID.main.id, remainingSeconds: seconds);
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown.remainingSeconds > 0) {
        countdown.remainingSeconds--;
        // Update the countdown record in the database
        MyApp.store.runInTransaction(TxMode.write, () {
          MyApp.store.box<Countdown>().put(countdown);
        });
      } else {
        timer.cancel();
        onTimerEnd();
      }
    });
  }
}
