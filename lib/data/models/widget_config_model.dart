import 'package:flutter/material.dart';

class AppWidgetTheme {
  const AppWidgetTheme({
    required this.name,
    required this.color,
    this.textColor = Colors.white,
    this.gradient,
  });

  final String name;
  final Color color;
  final Color textColor;
  final String? gradient;
}

class AppWidgetSize {
  const AppWidgetSize({
    required this.name,
    required this.size,
    this.isFree = true,
    this.isPopular = false,
  });

  final String name;
  final String size;
  final bool isFree;
  final bool isPopular;
}
