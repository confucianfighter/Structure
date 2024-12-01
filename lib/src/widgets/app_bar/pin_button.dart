import 'package:flutter/material.dart';
import 'dart:async';
import '../../functions/window_management.dart';

class PinToTopButton extends StatefulWidget {
  const PinToTopButton({super.key});

  @override
  _PinToTopButtonState createState() => _PinToTopButtonState();
}

class _PinToTopButtonState extends State<PinToTopButton> {
  bool isAlwaysOnTop = false;

  Future<void> toggleAlwaysOnTop() async {
    setState(() {
      isAlwaysOnTop = !isAlwaysOnTop;
    });
    await setAlwaysOnTop(isAlwaysOnTop);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isAlwaysOnTop ? Icons.push_pin : Icons.push_pin_outlined),
      onPressed: toggleAlwaysOnTop,
    );
  }
}
