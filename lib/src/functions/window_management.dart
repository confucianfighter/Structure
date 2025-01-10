import 'dart:async';
import 'package:Structure/src/utils/WindowControl.dart';

Future<bool> setAlwaysOnTop(bool isAlwaysOnTop) async {
  if (isAlwaysOnTop) {
    WindowControl().setAlwaysOnTop();
  } else {
    WindowControl().removeAlwaysOnTop();
  }
  return true;
}
