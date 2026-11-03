import '../core/plugin/omni_plugin.dart';
import '../core/plugin/plugin_registry.dart';
import '../features/dashboard/core_dashboard_plugin.dart';

List<OmniPlugin> builtinPlugins() => const <OmniPlugin>[CoreDashboardPlugin()];

PluginRegistry createPluginRegistry() {
  return PluginRegistry(builtinPlugins());
}
