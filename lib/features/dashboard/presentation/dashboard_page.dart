import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/i18n_context.dart';
import '../../../core/plugin/dashboard_panel.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../timetable/application/timetable_controller.dart';
import '../application/dashboard_controller.dart';
import 'widgets/panel_grid.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardController>();
    final panels = dashboard.panels;
    return ColoredBox(
      color: context.surfaces.page,
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth >= 1000 ? 32.0 : 16.0;
            final bottom = MediaQuery.paddingOf(context).bottom + 32;
            if (_editing) {
              return _EditorBody(
                panels: panels,
                availablePanels: dashboard.availablePanels,
                horizontal: horizontal,
                bottom: bottom,
                onDone: () => setState(() => _editing = false),
                onReset: dashboard.reset,
                onReorder: dashboard.move,
                onRemove: dashboard.remove,
                onAdd: dashboard.add,
              );
            }
            return ListView(
              padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, bottom),
              children: <Widget>[
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1360),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _DashboardHeader(
                          onEdit: () => setState(() => _editing = true),
                        ),
                        const SizedBox(height: 24),
                        if (panels.isEmpty)
                          _EmptyDashboard(
                            onReset: dashboard.reset,
                            onEdit: () => setState(() => _editing = true),
                          )
                        else
                          DashboardPanelGrid(panels: panels),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final timetable = context.watch<TimetableController>();
    final l10n = context.l10n;
    final snapshot = timetable.snapshot;
    final now = DateTime.now();
    final week = snapshot?.weekNumberFor(now) ?? 0;
    final weekLabel = snapshot == null
        ? null
        : week < 1
        ? l10n.dashboardWeekNotStarted
        : week > snapshot.totalWeeks
        ? l10n.dashboardWeekEnded
        : l10n.weekLabel(week);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.greeting(now.hour),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.dateWithWeekday(now),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.dashboardEditPanels,
              onPressed: onEdit,
              icon: const Icon(Icons.tune_rounded, size: 21),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        if (weekLabel != null ||
            snapshot != null ||
            timetable.busy ||
            timetable.error != null) ...<Widget>[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              if (weekLabel != null)
                StatusChip(
                  label: weekLabel,
                  icon: Icons.date_range_rounded,
                  tone: StatusTone.primary,
                ),
              if (snapshot != null)
                StatusChip(
                  label: snapshot.term.shortName,
                  icon: Icons.school_outlined,
                ),
              if (timetable.busy)
                StatusChip(
                  label: l10n.dashboardSyncing,
                  icon: Icons.sync_rounded,
                ),
              if (timetable.error != null)
                StatusChip(
                  label: l10n.dashboardSyncFailed,
                  icon: Icons.error_outline_rounded,
                  tone: StatusTone.error,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard({required this.onReset, required this.onEdit});

  final VoidCallback onReset;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SurfaceCard(
      child: EmptyState(
        icon: Icons.dashboard_customize_outlined,
        title: l10n.dashboardEmptyTitle,
        message: l10n.dashboardEmptyMessage,
        action: Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: <Widget>[
            FilledButton.tonal(
              onPressed: onEdit,
              child: Text(l10n.dashboardAddPanel),
            ),
            TextButton(
              onPressed: onReset,
              child: Text(l10n.dashboardResetDefault),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorBody extends StatelessWidget {
  const _EditorBody({
    required this.panels,
    required this.availablePanels,
    required this.horizontal,
    required this.bottom,
    required this.onDone,
    required this.onReset,
    required this.onReorder,
    required this.onRemove,
    required this.onAdd,
  });

  final List<DashboardPanelDefinition> panels;
  final List<DashboardPanelDefinition> availablePanels;
  final double horizontal;
  final double bottom;
  final VoidCallback onDone;
  final VoidCallback onReset;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(String panelId) onRemove;
  final void Function(String panelId) onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.dashboardEditTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.dashboardEditSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: context.colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onReset,
                child: Text(l10n.dashboardResetDefault),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: onDone,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: Text(l10n.commonDone),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: ReorderableListView.builder(
                padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, bottom),
                buildDefaultDragHandles: false,
                itemCount: panels.length,
                onReorderItem: onReorder,
                itemBuilder: (context, index) {
                  final panel = panels[index];
                  return Padding(
                    key: ValueKey(panel.id),
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _EditablePanelRow(
                      panel: panel,
                      index: index,
                      onRemove: panel.removable
                          ? () => onRemove(panel.id)
                          : null,
                    ),
                  );
                },
                footer: _AddablePanels(panels: availablePanels, onAdd: onAdd),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EditablePanelRow extends StatelessWidget {
  const _EditablePanelRow({
    required this.panel,
    required this.index,
    required this.onRemove,
  });

  final DashboardPanelDefinition panel;
  final int index;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SurfaceCard(
      radius: AppRadii.small + 4,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              panel.icon,
              size: 19,
              color: context.colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  panel.title(l10n),
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  panel.description(l10n),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              tooltip: l10n.dashboardRemovePanel,
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
            ),
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.drag_indicator_rounded,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddablePanels extends StatelessWidget {
  const _AddablePanels({required this.panels, required this.onAdd});

  final List<DashboardPanelDefinition> panels;
  final void Function(String panelId) onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionLabel(l10n.dashboardAddPanelSection),
          const SizedBox(height: 10),
          if (panels.isEmpty)
            Text(
              l10n.dashboardAllPanelsAdded,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: context.colors.onSurfaceVariant),
            )
          else
            for (final panel in panels)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SurfaceCard(
                  radius: AppRadii.small + 4,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(panel.icon, size: 20, color: context.colors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              panel.title(l10n),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              panel.description(l10n),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: context.colors.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: l10n.dashboardAddPanelTooltip(
                          panel.title(l10n),
                        ),
                        onPressed: () => onAdd(panel.id),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
