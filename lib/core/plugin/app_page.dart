import 'package:flutter/material.dart';

class AppPageDefinition {
  const AppPageDefinition({
    required this.id,
    required this.label,
    required this.icon,
    required this.builder,
    this.selectedIcon,
    this.order = 100,
  });

  final String id;
  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final int order;
  final Widget Function(BuildContext context) builder;
}
