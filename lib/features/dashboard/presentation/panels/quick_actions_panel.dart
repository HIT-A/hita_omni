import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/i18n_context.dart';
import '../../../../core/navigation/navigation_controller.dart';
import '../../../../core/theme/theme_controller.dart';
import '../widgets/panel_card.dart';

class QuickActionsPanel extends StatelessWidget {
  const QuickActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final l10n = context.l10n;

    return PanelCard(
      title: l10n.panelQuickActionsTitle,
      icon: Icons.bolt_rounded,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: <Widget>[
          OutlinedButton.icon(
            onPressed: () {
              context.read<NavigationController>().go(CorePageIds.timetable);
            },
            icon: const Icon(Icons.calendar_view_week_rounded, size: 18),
            label: Text(l10n.panelQuickActionsOpenTimetable),
          ),
          OutlinedButton.icon(
            onPressed: () {
              context.read<NavigationController>().go(CorePageIds.account);
            },
            icon: const Icon(Icons.person_outline_rounded, size: 18),
            label: Text(l10n.panelQuickActionsAccount),
          ),
          OutlinedButton.icon(
            onPressed: theme.cycle,
            icon: const Icon(Icons.contrast_rounded, size: 18),
            label: Text(
              l10n.panelQuickActionsAppearance(l10n.themeModeLabel(theme.mode)),
            ),
          ),
        ],
      ),
    );
  }
}
