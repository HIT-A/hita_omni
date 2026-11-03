import 'app_page.dart';
import 'dashboard_panel.dart';
import 'omni_plugin.dart';

class PluginRegistry {
  PluginRegistry(Iterable<OmniPlugin> plugins)
    : plugins = List<OmniPlugin>.unmodifiable(plugins) {
    final pluginIds = <String>{};
    final panelIds = <String>{};
    final pageIds = <String>{};
    final registeredPanels = <DashboardPanelDefinition>[];
    final registeredPages = <AppPageDefinition>[];

    for (final plugin in this.plugins) {
      if (!pluginIds.add(plugin.id)) {
        throw StateError('Duplicate plugin id: ${plugin.id}');
      }
      for (final panel in plugin.panels) {
        if (!panelIds.add(panel.id)) {
          throw StateError('Duplicate dashboard panel id: ${panel.id}');
        }
        registeredPanels.add(panel);
      }
      for (final page in plugin.pages) {
        if (!pageIds.add(page.id)) {
          throw StateError('Duplicate plugin page id: ${page.id}');
        }
        registeredPages.add(page);
      }
    }

    registeredPages.sort((a, b) => a.order.compareTo(b.order));
    panels = List<DashboardPanelDefinition>.unmodifiable(registeredPanels);
    pages = List<AppPageDefinition>.unmodifiable(registeredPages);
    _panelById = <String, DashboardPanelDefinition>{
      for (final panel in panels) panel.id: panel,
    };
  }

  final List<OmniPlugin> plugins;
  late final List<DashboardPanelDefinition> panels;
  late final List<AppPageDefinition> pages;
  late final Map<String, DashboardPanelDefinition> _panelById;

  DashboardPanelDefinition? panelById(String id) => _panelById[id];

  List<String> get defaultPanelIds => <String>[
    for (final panel in panels)
      if (panel.defaultEnabled) panel.id,
  ];
}
