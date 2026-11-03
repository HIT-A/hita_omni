import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hita_omni/core/plugin/dashboard_panel.dart';
import 'package:hita_omni/core/plugin/omni_plugin.dart';
import 'package:hita_omni/core/plugin/plugin_registry.dart';
import 'package:hita_omni/core/storage/key_value_store.dart';
import 'package:hita_omni/features/dashboard/application/dashboard_controller.dart';

class _TestPlugin extends OmniPlugin {
  @override
  String get id => 'test.plugin';

  @override
  String get name => 'Test';

  @override
  String get description => 'Test plugin';

  @override
  List<DashboardPanelDefinition> get panels => <DashboardPanelDefinition>[
    DashboardPanelDefinition(
      id: 'a',
      title: (_) => 'A',
      description: (_) => 'Panel A',
      icon: Icons.circle_outlined,
      defaultEnabled: true,
      builder: (_) => const SizedBox.shrink(),
    ),
    DashboardPanelDefinition(
      id: 'b',
      title: (_) => 'B',
      description: (_) => 'Panel B',
      icon: Icons.square_outlined,
      defaultEnabled: true,
      builder: (_) => const SizedBox.shrink(),
    ),
    DashboardPanelDefinition(
      id: 'c',
      title: (_) => 'C',
      description: (_) => 'Panel C',
      icon: Icons.star_outline_rounded,
      builder: (_) => const SizedBox.shrink(),
    ),
  ];
}

void main() {
  late MemoryKeyValueStore store;
  late DashboardController controller;

  DashboardController createController() {
    return DashboardController(
      registry: PluginRegistry(<OmniPlugin>[_TestPlugin()]),
      store: store,
    );
  }

  List<String> ids(DashboardController value) {
    return value.panels.map((panel) => panel.id).toList();
  }

  setUp(() {
    store = MemoryKeyValueStore();
    controller = createController();
  });

  test('starts from the default enabled panels', () {
    expect(ids(controller), <String>['a', 'b']);
    expect(controller.availablePanels.map((panel) => panel.id), <String>['c']);
  });

  test('adds, removes, and persists panels', () {
    controller.add('c');
    expect(ids(controller), <String>['a', 'b', 'c']);

    controller.remove('b');
    expect(ids(controller), <String>['a', 'c']);

    final reloaded = createController();
    expect(ids(reloaded), <String>['a', 'c']);
  });

  test('applies adjusted reorder indexes', () {
    controller.add('c');
    controller.move(0, 2);
    expect(ids(controller), <String>['b', 'c', 'a']);

    controller.move(2, 0);
    expect(ids(controller), <String>['a', 'b', 'c']);
  });

  test('resets to the default layout', () {
    controller.remove('a');
    controller.add('c');
    controller.reset();
    expect(ids(controller), <String>['a', 'b']);
  });
}
