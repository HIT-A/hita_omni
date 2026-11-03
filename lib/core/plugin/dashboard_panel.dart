import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

typedef DashboardPanelBuilder = Widget Function(BuildContext context);
typedef DashboardPanelText = String Function(AppLocalizations l10n);

class DashboardPanelDefinition {
  const DashboardPanelDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.builder,
    this.span = 1,
    this.defaultEnabled = false,
    this.removable = true,
  }) : assert(span > 0, 'A panel must occupy at least one column.');

  final String id;
  final DashboardPanelText title;
  final DashboardPanelText description;
  final IconData icon;

  /// Preferred number of dashboard columns. Layout clamps this to the number
  /// of columns available on the current screen.
  final int span;
  final bool defaultEnabled;
  final bool removable;
  final DashboardPanelBuilder builder;
}
