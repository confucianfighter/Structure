import 'dart:async';
import '../../data_store.dart';
import 'package:flutter/material.dart';

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
