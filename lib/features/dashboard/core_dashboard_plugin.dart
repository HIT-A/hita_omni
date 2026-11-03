import 'package:flutter/material.dart';

import '../../core/plugin/dashboard_panel.dart';
import '../../core/plugin/omni_plugin.dart';
import '../../l10n/app_localizations.dart';
import 'presentation/panels/account_panel.dart';
import 'presentation/panels/next_class_panel.dart';
import 'presentation/panels/quick_actions_panel.dart';
import 'presentation/panels/today_schedule_panel.dart';
import 'presentation/panels/week_progress_panel.dart';

class CoreDashboardPlugin extends OmniPlugin {
  const CoreDashboardPlugin();

  @override
  String get id => 'core.dashboard';

  @override
  String get name => '核心面板';

  @override
  String get version => '0.0.1';

  @override
  String get description => '今日课程、下一节课、教学周与账户状态。';

  @override
  String localizeName(AppLocalizations l10n) => l10n.pluginCoreName;

  @override
  String localizeDescription(AppLocalizations l10n) =>
      l10n.pluginCoreDescription;

  @override
  List<DashboardPanelDefinition> get panels => <DashboardPanelDefinition>[
    DashboardPanelDefinition(
      id: 'core.next_class',
      title: (l10n) => l10n.panelNextClassTitle,
      description: (l10n) => l10n.panelNextClassDescription,
      icon: Icons.schedule_rounded,
      span: 2,
      defaultEnabled: true,
      builder: (_) => const NextClassPanel(),
    ),
    DashboardPanelDefinition(
      id: 'core.today_schedule',
      title: (l10n) => l10n.panelTodayScheduleTitle,
      description: (l10n) => l10n.panelTodayScheduleDescription,
      icon: Icons.view_day_outlined,
      span: 2,
      defaultEnabled: true,
      builder: (_) => const TodaySchedulePanel(),
    ),
    DashboardPanelDefinition(
      id: 'core.week_progress',
      title: (l10n) => l10n.panelWeekProgressTitle,
      description: (l10n) => l10n.panelWeekProgressDescription,
      icon: Icons.timelapse_rounded,
      span: 1,
      defaultEnabled: true,
      builder: (_) => const WeekProgressPanel(),
    ),
    DashboardPanelDefinition(
      id: 'core.account',
      title: (l10n) => l10n.panelAccountTitle,
      description: (l10n) => l10n.panelAccountDescription,
      icon: Icons.person_outline_rounded,
      span: 1,
      defaultEnabled: true,
      builder: (_) => const AccountPanel(),
    ),
    DashboardPanelDefinition(
      id: 'core.quick_actions',
      title: (l10n) => l10n.panelQuickActionsTitle,
      description: (l10n) => l10n.panelQuickActionsDescription,
      icon: Icons.bolt_rounded,
      span: 2,
      builder: (_) => const QuickActionsPanel(),
    ),
  ];
}
