import 'dart:io';
import 'dart:async';
import 'dart:developer';

Future<bool> setAlwaysOnTop(bool isAlwaysOnTop) async {
  final result = await Process.run(
      'lib/src/AlwaysOnTop/bin/Debug/net9.0/AlwaysOnTop.exe',
      [isAlwaysOnTop.toString()]);

  if (result.exitCode != 0) {
    // Handle error if needed
    log('Error: ${result.stderr}');
    return false;
  } else {
    log('AlwaysOnTop has been set to $isAlwaysOnTop');
    return true;
  }
}
