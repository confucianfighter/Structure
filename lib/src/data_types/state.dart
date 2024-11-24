import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'state.g.dart';

@HiveType(typeId: 5)
class AppState {
  @HiveField(0)
  int? timeRemainingSeconds;
  @HiveField(1)
  Mode? mode;
  AppState.withDefaults()
      : timeRemainingSeconds = 60,
        mode = Mode.Session;

  // Default constructor
  AppState();
}
enum Mode {
  Quiz,
  Session,
  Break,
}
AppState getAppState() {
  if (!Hive.isBoxOpen('state')) {
    Hive.openBox('state').then((value) => null);
  }

  var box = Hive.box<AppState>('state');
  if (!box.containsKey('current')) {
    box.put('current', AppState.withDefaults());
  }
  return box.get('current') ?? AppState.withDefaults();
}

Future<void> setAppState(AppState state) async {
  var box = Hive.box<AppState>('state');
  await box.put('current', state);
}
Future<void> resetAppState() async {
  var box = Hive.box<AppState>('state');
  await box.delete('current');
}
// get listenable for current app state
Future<ValueListenable<Box<AppState>>?> getAppStateListenable() async {
  var box = Hive.box<AppState>('state');
  return box.listenable();
}
