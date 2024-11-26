import 'dart:async';
import 'dart:developer';

Future<T> defaultOnErr<T>(Future<T> Function() func, T default_value) async {
  try {
    return await func();
  } catch (e) {
    log('Error: $e');
    return default_value;
  }
}