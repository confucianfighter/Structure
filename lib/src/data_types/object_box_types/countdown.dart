import 'dart:async';
import '../../data_store.dart';

enum TimerID {
  main(id: 1);

  final int id;

  const TimerID({required this.id});
}

@Entity()
class Countdown {
  @Id(assignable: true)
  int id = 0;

  int remainingSeconds;

  Countdown({required this.id, required this.remainingSeconds});
}

// Returns a watch stream for the countdown with the given ID
Stream<Query<Countdown>> watchCountdown(TimerID id) {
  final countdownBox = Data().store.box<Countdown>();
  return countdownBox
      .query(Countdown_.id.equals(TimerID.main.id))
      .watch(triggerImmediately: true);
}
