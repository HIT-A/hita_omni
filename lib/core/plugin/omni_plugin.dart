import '../../l10n/app_localizations.dart';
import 'app_page.dart';
import 'dashboard_panel.dart';

/// A compile-time extension module.
///
/// Flutter cannot load arbitrary native Dart code at runtime, so a plugin is a
/// Dart package registered in the composition root. It can contribute Today
/// panels and whole navigation pages while the core stays small.
abstract class OmniPlugin {
  const OmniPlugin();

  String get id;

  String get name;

  String get description;

  String get version => '0.1.0';

  /// Plugins can use generated localizations without forcing every third-party
  /// plugin to provide translations.
  String localizeName(AppLocalizations l10n) => name;

  String localizeDescription(AppLocalizations l10n) => description;

  List<DashboardPanelDefinition> get panels =>
      const <DashboardPanelDefinition>[];

  List<AppPageDefinition> get pages => const <AppPageDefinition>[];
}
