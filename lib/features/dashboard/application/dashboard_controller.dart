import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/plugin/dashboard_panel.dart';
import '../../../core/plugin/plugin_registry.dart';
import '../../../core/storage/storage.dart';

const _layoutKey = 'dashboard.layout.v1';

class DashboardController extends ChangeNotifier {
  DashboardController({required this.registry, required this.store}) {
    _panelIds = _readLayout();
  }

  final PluginRegistry registry;
  final KeyValueStore store;
  late List<String> _panelIds;

  List<DashboardPanelDefinition> get panels {
    final result = <DashboardPanelDefinition>[];
    for (final id in _panelIds) {
      final panel = registry.panelById(id);
      if (panel != null) {
        result.add(panel);
      }
    }
    return result;
  }

  List<DashboardPanelDefinition> get availablePanels {
    final shown = _panelIds.toSet();
    return <DashboardPanelDefinition>[
      for (final panel in registry.panels)
        if (!shown.contains(panel.id)) panel,
    ];
  }

  bool contains(String panelId) => _panelIds.contains(panelId);

  void add(String panelId) {
    final panel = registry.panelById(panelId);
    if (panel == null || _panelIds.contains(panelId)) {
      return;
    }
    _panelIds = <String>[..._panelIds, panelId];
    _persist();
    notifyListeners();
  }

  void remove(String panelId) {
    final panel = registry.panelById(panelId);
    if (panel == null || !panel.removable) {
      return;
    }
    _panelIds = <String>[
      for (final id in _panelIds)
        if (id != panelId) id,
    ];
    _persist();
    notifyListeners();
  }

  void move(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _panelIds.length) {
      return;
    }
    final target = newIndex.clamp(0, _panelIds.length - 1).toInt();
    if (target == oldIndex) {
      return;
    }
    final ids = <String>[..._panelIds];
    final moved = ids.removeAt(oldIndex);
    ids.insert(target, moved);
    _panelIds = ids;
    _persist();
    notifyListeners();
  }

  void reset() {
    _panelIds = registry.defaultPanelIds;
    _persist();
    notifyListeners();
  }

  List<String> _readLayout() {
    final raw = store.getString(_layoutKey);
    if (raw == null) {
      return registry.defaultPanelIds;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return registry.defaultPanelIds;
      }
      final seen = <String>{};
      return <String>[
        for (final item in decoded)
          if (item is String && registry.panelById(item) != null)
            if (seen.add(item)) item,
      ];
    } on FormatException {
      return registry.defaultPanelIds;
    }
  }

  void _persist() {
    store.setString(_layoutKey, jsonEncode(_panelIds));
  }
}
