import 'package:flutter/material.dart';

import '../../../../core/plugin/dashboard_panel.dart';

const _maxContentWidth = 1360.0;

List<List<DashboardPanelDefinition>> packPanelRows(
  List<DashboardPanelDefinition> panels,
  int columns,
) {
  if (columns <= 0) {
    return const <List<DashboardPanelDefinition>>[];
  }
  final rows = <List<DashboardPanelDefinition>>[];
  var current = <DashboardPanelDefinition>[];
  var used = 0;

  for (final panel in panels) {
    final span = panel.span.clamp(1, columns).toInt();
    if (span >= columns) {
      if (current.isNotEmpty) {
        rows.add(current);
        current = <DashboardPanelDefinition>[];
        used = 0;
      }
      rows.add(<DashboardPanelDefinition>[panel]);
      continue;
    }
    if (used + span > columns) {
      rows.add(current);
      current = <DashboardPanelDefinition>[];
      used = 0;
    }
    current.add(panel);
    used += span;
    if (used == columns) {
      rows.add(current);
      current = <DashboardPanelDefinition>[];
      used = 0;
    }
  }
  if (current.isNotEmpty) {
    rows.add(current);
  }
  return rows;
}

class DashboardPanelGrid extends StatelessWidget {
  const DashboardPanelGrid({super.key, required this.panels, this.gap = 16});

  final List<DashboardPanelDefinition> panels;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1160
            ? 3
            : width >= 700
            ? 2
            : 1;
        final rows = packPanelRows(panels, columns);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Column(
              children: <Widget>[
                for (var rowIndex = 0; rowIndex < rows.length; rowIndex++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: rowIndex == rows.length - 1 ? 0 : gap,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        for (
                          var index = 0;
                          index < rows[rowIndex].length;
                          index++
                        ) ...<Widget>[
                          if (index > 0) SizedBox(width: gap),
                          Expanded(
                            flex: rows[rowIndex][index].span
                                .clamp(1, columns)
                                .toInt(),
                            child: KeyedSubtree(
                              key: ValueKey(rows[rowIndex][index].id),
                              child: rows[rowIndex][index].builder(context),
                            ),
                          ),
                        ],
                        if (_usedSpan(rows[rowIndex], columns) < columns)
                          Expanded(
                            flex: columns - _usedSpan(rows[rowIndex], columns),
                            child: const SizedBox.shrink(),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _usedSpan(List<DashboardPanelDefinition> row, int columns) {
    return row.fold<int>(
      0,
      (sum, panel) => sum + panel.span.clamp(1, columns).toInt(),
    );
  }
}
