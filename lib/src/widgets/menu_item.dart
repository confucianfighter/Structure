import 'package:flutter/material.dart';
/// A placeholder class that represents an entity or model.
class MenuItem {
  const MenuItem({
    required this.id,
    required this.title,
    required this.route,
    this.icon,
  });
  final int id;
  final String route;
  final Icon? icon;
  final String title;
}
